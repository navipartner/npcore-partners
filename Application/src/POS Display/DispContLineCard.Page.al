﻿page 6059999 "NPR Disp. Cont. Line Card"
{
    Extensible = False;
    Caption = 'Display Content Line Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Display Content Lines";
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Url; Rec.Url)
                {

                    Visible = UrlIsVisible;
                    ToolTip = 'Specifies the value of the Url field';
                    ApplicationArea = NPRRetail;
                }
                field(Image; Rec.Picture)
                {

                    Visible = ImageIsVisible;
                    ToolTip = 'Specifies the value of the Image field';
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
        area(factboxes)
        {
            part(DispContentLinesImg; "NPR Disp. Content Lines Img")
            {

                Caption = 'Picture';
                SubPageLink = "Content Code" = field("Content Code"),
                              "Line No." = field("Line No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if (DisplayContent.Type = DisplayContent.Type::Html) then begin
            Clear(DisplayContentLines);
            DisplayContentLines.SetRange("Content Code", DisplayContent.Code);
            if DisplayContentLines.Count > 0 then
                Error(Txt001);
        end;
    end;

    trigger OnOpenPage()
    begin

        DisplayContent.Get(Rec.GetFilter("Content Code"));
        if (DisplayContent.Type = DisplayContent.Type::Image) then begin
            ImageIsVisible := true;
            UrlIsVisible := false;
        end else begin
            ImageIsVisible := false;
            UrlIsVisible := true;
        end;
    end;

    var
        UrlIsVisible: Boolean;
        ImageIsVisible: Boolean;
        DisplayContent: Record "NPR Display Content";
        DisplayContentLines: Record "NPR Display Content Lines";
        Txt001: Label 'Only 1 webpage url is allowed';
}

