package
{
	public class BoscaStringUtil
	{
		
	     public static function repeat(str:String,n:int):String
          {
               var outStr:String = "";

               for(var i:int = 0;i < n;i++)
                    outStr += str;

               return outStr;   
          }
		
	}
}
