package simpleboilerpipe;

import java.io.IOException;

import org.xml.sax.InputSource;

import de.l3s.boilerpipe.document.TextDocument;
import de.l3s.boilerpipe.extractors.ArticleExtractor;
import de.l3s.boilerpipe.extractors.DefaultExtractor;
import de.l3s.boilerpipe.sax.BoilerpipeSAXInput;

public class simpleboilerpipe
{
	public static void main(String[] args) throws IOException
	{
		if (args.length < 2)
		{
			System.out.println("Usage : boilerpipe (article|default) url");
		}
		else
		{
			String method = args[0];
			String url = args[1];
			
		    try
		    {
				InputSource is = new InputSource(url);
			    BoilerpipeSAXInput in = new BoilerpipeSAXInput(is);
			    TextDocument doc = in.getTextDocument();
		
			    if (method.equals("default"))
			    	System.out.println(DefaultExtractor.INSTANCE.getText(doc));
			    else if (method.equals("article"))
			    	System.out.println(ArticleExtractor.INSTANCE.getText(doc));
			    else
			    	System.out.println("Error: '" + method + "' Method unkown");
		    }
		    catch (Exception e)
		    {
		    	System.out.println("Error : " + e.getMessage());
		    }
		}
	}
}