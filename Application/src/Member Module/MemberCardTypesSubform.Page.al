page 6059776 "NPR Member Card Types Subform"
{
    Caption = 'Point Card - Types Subform';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Member Card Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Base Calculation On"; "Base Calculation On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base Calculation On field';
                }
                field("Units Per Point"; "Units Per Point")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Units Per Point field';
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field';
                }
                field("Customer Group"; "Customer Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Group field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
            }
        }
    }

    actions
    {
    }
}

