page 6014575 "NPR Package Printers"
{

    PageType = List;
    SourceTable = "NPR Package Printers";
    caption = 'NPR Package Printers';
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of Printer on shipmondo';
                }
                field("Host Name"; Rec."Host Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Host Name of Server';
                }
                field(Printer; Rec.Printer)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of Printer on server';
                }
                field("Label Format"; Rec."Label Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Label format from external shipping service';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Location for which Printer to use';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the User that will use the Corresponding Printer';
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the User Name that will use the Corresponding Printer';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GetPrinter)
            {
                Caption = 'Get printers';
                ApplicationArea = All;
                ToolTip = 'Executes the Get printers action';
            }
        }
    }
}

