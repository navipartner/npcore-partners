xmlport 6059937 "Rss Reader Activity Import"
{
    // NPR5.25/TS/20160510  CASE 233762 Added Sorting of page on Published At

    Caption = 'Rss Reader Activity Import';

    schema
    {
        textelement(rss)
        {
            textelement(channel)
            {
                tableelement("RSS Reader Activity";"RSS Reader Activity")
                {
                    XmlName = 'item';
                    UseTemporary = true;
                    fieldelement(link;"RSS Reader Activity".Link)
                    {

                        trigger OnAfterAssignField()
                        begin
                            RssReaderActivityTemp.Link := "RSS Reader Activity".Link;
                        end;
                    }
                    fieldelement(title;"RSS Reader Activity".Title)
                    {

                        trigger OnAfterAssignField()
                        begin
                            RssReaderActivityTemp.Title := "RSS Reader Activity".Title;
                        end;
                    }
                    textelement(pubDate)
                    {

                        trigger OnAfterAssignVariable()
                        begin
                            "RSS Reader Activity"."Published At" := xmlconvert.ToDateTime(pubDate);
                            RssReaderActivityTemp."Published At" := "RSS Reader Activity"."Published At";
                        end;
                    }

                    trigger OnAfterInitRecord()
                    begin
                        //"RSS Reader Activity".Code := RssFeedCode;
                        RssReaderActivityTemp.Init;
                    end;

                    trigger OnAfterInsertRecord()
                    begin
                        RssReaderActivityTemp.Insert;
                    end;

                    trigger OnBeforeInsertRecord()
                    begin
                        RssReaderActivityTemp.Code := RssFeedCode;
                    end;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Rss Reader Activity Import';

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    begin
        //RssReaderActivity.DELETEALL;
        //-NPR5.25
        RssReaderActivityTemp.SetCurrentKey("Published At");
        RssReaderActivityTemp.Ascending (false);
        //+NPR5.25
    end;

    var
        RssReaderActivityTemp: Record "RSS Reader Activity" temporary;
        xmlconvert: DotNet npNetXmlConvert;
        RssFeedCode: Code[20];

    procedure SetRssFeedCode(RssFeedCodeHere: Code[20])
    begin
        RssFeedCode := RssFeedCodeHere;
    end;

    procedure GetRssActivityRec(var RssReaderActivityTempHere: Record "RSS Reader Activity" temporary)
    begin
        RssReaderActivityTempHere.Copy(RssReaderActivityTemp,true);
    end;
}

