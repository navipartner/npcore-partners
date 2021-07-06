page 6150704 "NPR POS Action Param."
{
    Caption = 'POS Action Parameters';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Action Parameter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';

                    trigger OnValidate()
                    begin
                        SetOptionsEditable();
                    end;
                }
                field(Options; Rec.Options)
                {
                    ApplicationArea = All;
                    Editable = OptionsEditable;
                    ToolTip = 'Specifies the value of the Options field';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Value field';
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

