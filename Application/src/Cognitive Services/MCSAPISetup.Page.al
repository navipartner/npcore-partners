page 6059955 "NPR MCS API Setup"
{

    Caption = 'MCS API Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MCS API Setup";
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(API; Rec.API)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API field';
                }
                field(BaseURLText; BaseURLText)
                {
                    ApplicationArea = All;
                    Caption = 'Base URL';
                    ToolTip = 'Specifies the value of the BaseURL field';
                    trigger OnValidate()
                    begin
                        Rec.SetBaseUrl(BaseURLText);
                    end;
                }
                field("Key 1"; Rec."Key 1")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Key 1 field';
                }
                field("Key 2"; Rec."Key 2")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Key 2 field';
                }
                field("Image Orientation"; Rec."Image Orientation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Orientation field';
                }
                field("Use Cognitive Services"; Rec."Use Cognitive Services")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Cognitive Services field';
                }
            }
        }
    }

    trigger OnAfterGetRecord()

    begin
        BaseURLText := Rec.GetBaseUrl();
    end;

    var
        BaseURLText: Text;

}

