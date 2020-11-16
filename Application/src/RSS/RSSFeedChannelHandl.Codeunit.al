codeunit 6059937 "NPR RSS Feed Channel Handl."
{
    // NPR5.22/TJ/20160407 CASE 233762 Added new function ImportRss


    trigger OnRun()
    begin
    end;

    procedure ImportRss(RssFeedChannelSub: Record "NPR RSS Feed Channel Sub."; var RssReaderActivity: Record "NPR RSS Reader Activity" temporary)
    var
        XRss: DotNet NPRNetXDocument;
        SimplifiedRss: DotNet NPRNetXDocument;
        rss: DotNet NPRNetXElement;
        channel: DotNet NPRNetXElement;
        item: DotNet NPRNetXElement;
        FeedDate: Text;
        xName: DotNet NPRNetXName;
        rssNew: DotNet NPRNetXElement;
        channelNew: DotNet NPRNetXElement;
        itemNew: DotNet NPRNetXElement;
        link: DotNet NPRNetXElement;
        title: DotNet NPRNetXElement;
        date: DotNet NPRNetXElement;
        list: DotNet NPRNetIEnumerable_Of_T;
        RssReaderActivityImport: XMLport "NPR Rss Reader Activity Import";
        MemoryStream: DotNet NPRNetMemoryStream;
        Encoding: DotNet NPRNetUTF32Encoding;
        DateTimeParser: DotNet NPRNetDateTime;
        NetConvHelper: Variant;
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
            itemNew.SetElementValue(link.Name, link.Value);
            itemNew.SetElementValue(title.Name, title.Value);
            itemNew.SetElementValue(date.Name, DateTimeParser.Parse(date.Value));
        end;

        RssReaderActivityImport.SetRssFeedCode(RssFeedChannelSub."Feed Code");
        NetConvHelper := MemoryStream.MemoryStream(Encoding.UTF32Encoding.GetBytes(SimplifiedRss.ToString));
        RssReaderActivityImport.SetSource(NetConvHelper);
        RssReaderActivityImport.Import;
        RssReaderActivityImport.GetRssActivityRec(RssReaderActivity);
    end;

    procedure GetChannelCodeString() ChannelCodeString: Text
    var
        RSSFeedChannelSubscription: Record "NPR RSS Feed Channel Sub.";
    begin
        if RSSFeedChannelSubscription.FindSet then
            repeat
                ChannelCodeString += ',' + RSSFeedChannelSubscription."Feed Code";
            until RSSFeedChannelSubscription.Next = 0;
        ChannelCodeString := CopyStr(ChannelCodeString, 2);
    end;
}

