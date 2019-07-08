codeunit 6059937 "RSS Feed Channel Handling"
{
    // NPR5.22/TJ/20160407 CASE 233762 Added new function ImportRss


    trigger OnRun()
    begin
    end;

    procedure ImportRss(RssFeedChannelSub: Record "RSS Feed Channel Subscription";var RssReaderActivity: Record "RSS Reader Activity" temporary)
    var
        XRss: DotNet XDocument;
        SimplifiedRss: DotNet XDocument;
        rss: DotNet XElement;
        channel: DotNet XElement;
        item: DotNet XElement;
        FeedDate: Text;
        xName: DotNet XName;
        rssNew: DotNet XElement;
        channelNew: DotNet XElement;
        itemNew: DotNet XElement;
        link: DotNet XElement;
        title: DotNet XElement;
        date: DotNet XElement;
        list: DotNet IEnumerable_Of_T;
        RssReaderActivityImport: XMLport "Rss Reader Activity Import";
        MemoryStream: DotNet MemoryStream;
        Encoding: DotNet UTF32Encoding;
        DateTimeParser: DotNet DateTime;
    begin
        XRss := XRss.Load(RssFeedChannelSub.Url);
        rss := XRss.Element(xName.Get('rss'));
        channel := rss.Element(xName.Get('channel'));

        SimplifiedRss := SimplifiedRss.XDocument();
        rssNew := rssNew.XElement(rss.Name);
        SimplifiedRss.Add(rssNew);
        channelNew := channelNew.XElement(channel.Name);
        rssNew.Add(channelNew);
        list := channel.Elements(xName.Get('item'));

        foreach item in list do begin
          date := item.Element(xName.Get('pubDate'));
          title := item.Element(xName.Get('title'));
          link := item.Element(xName.Get('link'));
          itemNew := itemNew.XElement(item.Name);
          channelNew.Add(itemNew);
          itemNew.SetElementValue(link.Name,link.Value);
          itemNew.SetElementValue(title.Name,title.Value);
          itemNew.SetElementValue(date.Name,DateTimeParser.Parse(date.Value));
        end;

        RssReaderActivityImport.SetRssFeedCode(RssFeedChannelSub."Feed Code");
        RssReaderActivityImport.SetSource(MemoryStream.MemoryStream(Encoding.UTF32Encoding.GetBytes(SimplifiedRss.ToString)));
        RssReaderActivityImport.Import;
        RssReaderActivityImport.GetRssActivityRec(RssReaderActivity);
    end;

    procedure GetChannelCodeString() ChannelCodeString: Text
    var
        RSSFeedChannelSubscription: Record "RSS Feed Channel Subscription";
    begin
        if RSSFeedChannelSubscription.FindSet then repeat
          ChannelCodeString += ',' + RSSFeedChannelSubscription."Feed Code";
        until RSSFeedChannelSubscription.Next = 0;
        ChannelCodeString := CopyStr(ChannelCodeString,2);
    end;
}

