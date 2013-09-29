package
{
	import flash.display.*;
	import flash.geom.*;
  	import flash.events.*;
  import flash.net.*;
	import flash.media.*;
  import flash.ui.ContextMenu;
  import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import bigroom.input.KeyPoll;
  import flash.ui.Mouse;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.events.InvokeEvent;
	import flash.desktop.NativeApplication;
	import com.victordramba.console.*;
	
	/**
	 * Application entry-point
	 */
	public class Applicationlinux extends Sprite
	{
	  	include "keypoll.as";
	  	include "includes/logic.as";
	  	include "includes/input.as";
	  	include "includes/render.as";
	  	
	 	public function Applicationlinux()
		{
				//Debugger.setParent(this, true);
		
			//NativeApplication.nativeApplication.setAsDefaultApplication("ceol");
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			key = new KeyPoll(stage);
			control = new controlclass();
			gfx.init();
			var tempbmp:Bitmap;
			tempbmp = new im_icons();	gfx.buffer = tempbmp.bitmapData;	gfx.makeiconarray();
			gfx.buffer = new BitmapData(384, 240, false, 0x000000);
			control.voicelist.fixlengths(gfx);
			stage.fullScreenSourceRect = new Rectangle(0, 0, 768, 480);
			addChild(gfx);

			
			control.loadscreensettings(gfx);
			updategraphicsmode(control);
			_timer.addEventListener(TimerEvent.TIMER, mainloop);
			_timer.start();
		}
		public function _input():void {
			control.mx = (mouseX / gfx.screenscale);
			control.my = (mouseY /  gfx.screenscale);
				
			input(key, gfx, control);
		}
		
    public function _logic():void {
			logic(key, gfx, control);
			help.updateglow();
		}
		
		public function _render():void {
			gfx.backbuffer.lock();
			render(key, gfx, control);			
		}
		
		public function mainloop(e:TimerEvent):void {
			_current = getTimer();
			if (_last < 0) _last = _current;
			_delta += _current - _last;
			_last = _current;
			if (_delta >= _rate){
				_delta %= _skip;
				while (_delta >= _rate){
					_delta -= _rate;
					_input();
					_logic();
					if (key.hasclicked) key.click = false;
					if (key.hasrightclicked) key.rightclick = false;
					if (key.hasmiddleclicked) key.middleclick = false;
				}
				_render();
				e.updateAfterEvent();
			}
		}
		
		public function updategraphicsmode(control:controlclass):void {
		 	if (control.fullscreen) {
		 		//workaround of a bug that mess up rendering when switching back from fullscreen
	 			gfx.screenscale = 2;
				gfx.changewindowsize(2);
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}else {

				stage.displayState = StageDisplayState.NORMAL;
				
			}
			control.savescreensettings(gfx);
		}
		
		public function onInvokeEvent(event:InvokeEvent):void{
			if (event.arguments.length > 0) {
				if (control.startup == 0) {
					//Loading a song at startup, wait until the sound is initilised
					control.invokefile = event.arguments[0];
				}else {
					//Program is up and running, just load now
					control.invokeceol(event.arguments[0]);
				}
			}
		}
		
		public var gfx:graphicsclass = new graphicsclass();
		public var control:controlclass;
		public var key:KeyPoll;
		
		// Timer information (a shout out to ChevyRay for the implementation)
		public static const TARGET_FPS:Number = 60; // the fixed-FPS we want the control to run at
		private var	_rate:Number = 1000 / TARGET_FPS; // how long (in seconds) each frame is
		private var	_skip:Number = _rate * 10; // this tells us to allow a maximum of 10 frame skips
		private var	_last:Number = -1;
		private var	_current:Number = 0;
		private var	_delta:Number = 0;
		private var	_timer:Timer = new Timer(4);
		
		//Embedded resources:		
		[Embed(source = 'graphics/icons.png')]	private var im_icons:Class;
	}
}
