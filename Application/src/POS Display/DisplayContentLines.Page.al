page 6059952 "NPR Display Content Lines"
{
    Extensible = False;
    Caption = 'Display Content Lines';
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    Editable = false;
    SourceTable = "NPR Display Content Lines";
    CardPageId = "NPR Disp. Cont. Line Card";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Url; Rec.Url)
                {

                    Visible = UrlIsVisible;
                    ToolTip = 'Specifies the value of the Url field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6014404; "NPR Disp. Content Lines Img")
            {
                SubPageLink = "Content Code" = FIELD("Content Code"),
                              "Line No." = FIELD("Line No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if (DisplayContent.Type = DisplayContent.Type::Html) then begin
            Clear(DisplayContentLines);
            DisplayContentLines.SetRange("Content Code", DisplayContent.Code);
            if DisplayContentLines.Count() > 0 then
                Error(Txt001);
        end;
    end;

    trigger OnOpenPage()
    begin
        DisplayContent.Get(Rec.GetFilter("Content Code"));
        if (DisplayContent.Type = DisplayContent.Type::Image) then begin
            UrlIsVisible := false;
        end else begin
            UrlIsVisible := true;
        end;
    end;

    var
        UrlIsVisible: Boolean;
        DisplayContent: Record "NPR Display Content";
        DisplayContentLines: Record "NPR Display Content Lines";
        Txt001: Label 'Only 1 webpage url is allowed';
}

