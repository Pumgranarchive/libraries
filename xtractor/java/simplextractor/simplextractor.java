package simplextractor;

import java.io.ByteArrayInputStream;
import java.io.StringWriter;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

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
    private static InputStream readInput(int contentLength)
    {
        BufferedReader bufferReader = new BufferedReader(new InputStreamReader(System.in));

        int length = 0;
        String content = "";
        boolean finished = false;
        while (!finished && length < contentLength)
        {
            try
            {
                String line = bufferReader.readLine();
                length += line.length() + 1;
                content += line;
                if (line.matches(".*</html>[ \t]*$")) finished = true;
            }
            catch (Throwable ex)
            {
                break;
            }
        }

        return (new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8)));
    }

    public static void main(String[] args) throws Exception
    {
        try
        {
            Extractor extractor = new Extractor(null);
            ISummarizer summarizer = Factory.getSummarizer();

            int summarySentenceNb = 1;
            String url = args[0];
            int contentLength = Integer.parseInt(args[1]);
            InputStream html = readInput(contentLength);
            String charset = "UTF-8";
            ExtractorResult extracted = extractor.extract(html, charset, url);
            String summary = summarizer.summarize(extracted.getText(), summarySentenceNb);

            JSONObject json = new JSONObject();
            json.put("title", SHelper.replaceSmartQuotes(extracted.getTitle()));
            json.put("body", SHelper.replaceSmartQuotes(extracted.getText()));
            json.put("summary", SHelper.replaceSmartQuotes(summary));
            // json.put("image", extracted.getImage());
            // json.put("video", extracted.getVideo());
            System.out.print(json.toString());

        }
        catch (Throwable ex)
        {
            ex.printStackTrace();
        }

    }
}
