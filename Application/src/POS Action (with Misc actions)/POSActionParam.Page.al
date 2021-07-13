page 6150704 "NPR POS Action Param."
{
    Caption = 'POS Action Parameters';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Action Parameter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type"; Rec."Data Type")
                {

                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetOptionsEditable();
                    end;
                }
                field(Options; Rec.Options)
                {

                    Editable = OptionsEditable;
                    ToolTip = 'Specifies the value of the Options field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Value"; Rec."Default Value")
                {

                    ToolTip = 'Specifies the value of the Default Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetOptionsEditable();
    end;

    var
        OptionsEditable: Boolean;

    local procedure SetOptionsEditable()
    begin
        OptionsEditable := Rec."Data Type" = Rec."Data Type"::Option;
    end;
}

