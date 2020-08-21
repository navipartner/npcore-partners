page 6150704 "POS Action Parameters"
{
    Caption = 'POS Action Parameters';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "POS Action Parameter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetOptionsEditable();
                    end;
                }
                field(Options; Options)
                {
                    ApplicationArea = All;
                    Editable = OptionsEditable;
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
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

