page 6059955 "NPR MCS API Setup"
{

    Caption = 'MCS API Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MCS API Setup";
    DelayedInsert = true;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(API; Rec.API)
                {

                    ToolTip = 'Specifies the value of the API field';
                    ApplicationArea = NPRRetail;
                }
                field(BaseURLText; BaseURLText)
                {

                    Caption = 'Base URL';
                    ToolTip = 'Specifies the value of the BaseURL field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        Rec.SetBaseUrl(BaseURLText);
                    end;
                }
                field("Key 1"; Rec."Key 1")
                {

                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Key 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Key 2"; Rec."Key 2")
                {

                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Key 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Image Orientation"; Rec."Image Orientation")
                {

                    ToolTip = 'Specifies the value of the Image Orientation field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Cognitive Services"; Rec."Use Cognitive Services")
                {

                    ToolTip = 'Specifies the value of the Use Cognitive Services field';
                    ApplicationArea = NPRRetail;
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

