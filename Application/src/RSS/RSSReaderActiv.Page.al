page 6059995 "NPR RSS Reader Activ."
{
    // NPR5.22/TJ/20160415 CASE 233762 Reworked how to read RSS feeds
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'RSS Activities';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR RSS Reader Activity";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("RssFeedChannelSub.""Feed Code"""; RssFeedChannelSub."Feed Code")
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the RssFeedChannelSub.Feed Code field';
            }
            repeater(Group)
            {
                field(Title; Title)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Highlight;
                    ToolTip = 'Specifies the value of the Title field';
                }
                field(Link; Link)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    Style = Attention;
                    StyleExpr = Highlight;
                    ToolTip = 'Specifies the value of the Link field';
                }
                field("Published At"; "Published At")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Highlight;
                    ToolTip = 'Specifies the value of the Published At field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Highlight;
                    ToolTip = 'Specifies the value of the Status field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Change)
            {
                Caption = 'Change';
                Image = Change;
                ShortCutKey = 'Return';
                ApplicationArea = All;
                ToolTip = 'Executes the Change action';

                trigger OnAction()
                begin
                    ChangeChannelLookup();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ApplyHighlight();
    end;

    trigger OnOpenPage()
    begin
        if LoadDefault then
            ImportRss(RssFeedChannelSub);
    end;

    var
        RSSFeedChannelHandling: Codeunit "NPR RSS Feed Channel Handl.";
        Highlight: Boolean;
        Status: Text;
        RssFeedChannelSub: Record "NPR RSS Feed Channel Sub.";
        StatusText: Label 'New';

    local procedure LoadDefault(): Boolean
    begin
        RssFeedChannelSub.SetRange(Default, true);
        exit(RssFeedChannelSub.FindFirst);
    end;

    local procedure ImportRss(RssFeedChSub: Record "NPR RSS Feed Channel Sub.")
    begin
        if RssFeedChSub.Url <> '' then
            RSSFeedChannelHandling.ImportRss(RssFeedChSub, Rec);
        CurrPage.Update(false);
    end;

    local procedure ApplyHighlight()
    begin
        Highlight := false;
        if not RssFeedChannelSub.IsEmpty then
            if Format(RssFeedChannelSub."Show as New Within") <> '' then begin
                Status := '';
                Highlight := CreateDateTime(CalcDate('-' + Format(RssFeedChannelSub."Show as New Within"), Today), Time) < "Published At";
                if Highlight then
                    Status := StatusText;
            end;
    end;

    local procedure ChangeChannelLookup()
    var
        RssFeedChannelSubscriptions: Page "NPR RSS Feed Channel Sub.";
    begin
        RssFeedChannelSub.SetRange(Default);
        RssFeedChannelSubscriptions.LookupMode(true);
        RssFeedChannelSubscriptions.SetTableView(RssFeedChannelSub);
        if RssFeedChannelSubscriptions.RunModal = ACTION::LookupOK then begin
            RssFeedChannelSubscriptions.GetRecord(RssFeedChannelSub);
            ImportRss(RssFeedChannelSub);
        end;
    end;
}

