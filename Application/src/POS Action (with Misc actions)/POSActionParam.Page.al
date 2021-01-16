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
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';

                    trigger OnValidate()
                    begin
                        SetOptionsEditable();
                    end;
                }
                field(Options; Options)
                {
                    ApplicationArea = All;
                    Editable = OptionsEditable;
                    ToolTip = 'Specifies the value of the Options field';
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Value field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetOptionsEditable();
    end;

    var
        OptionsEditable: Boolean;

    local procedure SetOptionsEditable()
    begin
        OptionsEditable := "Data Type" = "Data Type"::Option;
    end;
}

