package simplextractor;

import java.io.ByteArrayInputStream;
import java.io.StringWriter;

import org.apache.commons.io.IOUtils;
import org.json.JSONObject;

import com.mohaps.tldr.summarize.Factory;
import com.mohaps.tldr.summarize.ISummarizer;
import com.mohaps.xtractor.Extractor;
import com.mohaps.xtractor.ExtractorResult;
import com.mohaps.fetch.FetchResult;
import com.mohaps.fetch.Fetcher;

import de.jetwick.snacktory.SHelper;

public class simplextractor
{
    public static void main(String[] args) throws Exception
    {
        Fetcher fetcher = new Fetcher();

        try
        {
            Extractor extractor = new Extractor(fetcher);
            ISummarizer summarizer = Factory.getSummarizer();

            int summarySentenceNb = 1;
            String url = args[0];
            FetchResult fResult = fetcher.fetch(url);
            ExtractorResult eResult = extractor.extract(fResult.getContent(), fResult.getCharset(), fResult.getActualUrl());

            ByteArrayInputStream inputStream = new ByteArrayInputStream(fResult.getContent());
            StringWriter writer = new StringWriter();
            IOUtils.copy(inputStream, writer, fResult.getCharset());
            String content = writer.toString().replaceAll("( |\t|\n)+", " ").replaceAll(" ?> ?", ">").replaceAll(" ?< ?", "<").replaceAll(" ?; ?", ";");


            // System.out.print("title:  \t"+ SHelper.replaceSmartQuotes(eResult.getTitle()) + "\n");
            // System.out.print("summary:\t"+ SHelper.replaceSmartQuotes(summarizer.summarize(eResult.getText(), summarySentenceNb)) + "\n");
            // System.out.print("image:  \t"+ eResult.getImage() + "\n");
            // System.out.print("video:  \t"+ eResult.getVideo() + "\n");
            // System.out.print("body:   \t"+ SHelper.replaceSmartQuotes(eResult.getText()) + "\n");
            // System.out.print("\n");

            JSONObject json = new JSONObject();
            json.put("title", SHelper.replaceSmartQuotes(eResult.getTitle()));
            json.put("body", SHelper.replaceSmartQuotes(eResult.getText()));
            json.put("summary", SHelper.replaceSmartQuotes(summarizer.summarize(eResult.getText(), summarySentenceNb)));
            json.put("image", eResult.getImage());
            json.put("video", eResult.getVideo());
            json.put("content", content);
            System.out.print(json.toString());

            fetcher.shutdown();
        }
        catch (Throwable ex)
        {
            ex.printStackTrace();
            fetcher.shutdown();
        }


    }
}
