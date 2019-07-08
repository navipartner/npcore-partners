page 6060014 "GIM - Mapping Table Fields"
{
    Caption = 'GIM - Mapping Table Fields';
    PageType = List;
    SourceTable = "GIM - Mapping Table Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field ID";"Field ID")
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Field Type";"Field Type")
                {
                    Editable = false;
                }
                field(Mapped;Mapped)
                {
                }
                field("Field Additional Info";"Field Additional Info")
                {
                    Editable = false;
                }
                field("Value Type";"Value Type")
                {
                }
                field(Value;"Formatted Value")
                {
                    Editable = ValueEditable;
                }
                field("No. Series Code Rule";"No. Series Code Rule")
                {
                }
                field("Use on Table ID";"Use on Table ID")
                {
                }
                field("Use on Field ID";"Use on Field ID")
                {
                }
                field("Modify Value";"Modify Value")
                {
                }
                field("Validate Field";"Validate Field")
                {
                }
                field("Automatically Created";"Automatically Created")
                {
                    Editable = false;
                }
                field("From Table ID";"From Table ID")
                {
                }
                field("From Table Caption";"From Table Caption")
                {
                }
                field("From Field ID";"From Field ID")
                {
                }
                field("From Field Caption";"From Field Caption")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ValueEditable := ("Value Type" <> "Value Type"::Incremental) and ("Value Type" <> "Value Type"::Specific);
    end;

    var
        [InDataSet]
        ValueEditable: Boolean;
}

