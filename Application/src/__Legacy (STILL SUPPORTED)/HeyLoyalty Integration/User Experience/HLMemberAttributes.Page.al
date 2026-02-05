page 6150754 "NPR HL Member Attributes"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    Caption = 'HeyLoyalty Member Attributes';
    Editable = false;
    PageType = List;
    SourceTable = "NPR HL Member Attribute";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("HeyLoyalty Member Entry No."; Rec."HeyLoyalty Member Entry No.")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the HeyLoyalty member entry number.';
                    Visible = false;
                }
                field("Attribute Code"; Rec."Attribute Code")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the attribute code.';
                }
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the descriptive name of the attribute.';
                    Visible = false;
                }
                field(AttributeValueCode; Rec."Attribute Value Code")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the attribute value code.';
                }
                field("Attribute Value Name"; Rec."Attribute Value Name")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the descriptive name of the attribute value.';
                }
                field("HeyLoyalty Attribute Value"; Rec."HeyLoyalty Attribute Value")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies value of the attribute at HeyLoyalty.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if PageCaptionText <> '' then
            CurrPage.Caption := PageCaptionText;
    end;

    var
        PageCaptionText: Text[250];

    procedure SetFormCaption(NewPageCaption: Text[250])
    begin
        PageCaptionText := CopyStr(NewPageCaption + ' - ' + CurrPage.Caption, 1, MaxStrLen(PageCaptionText));
    end;
}