page 6014575 "NPR Package Printers"
{

    PageType = List;
    SourceTable = "NPR Package Printers";
    caption = 'NPR Package Printers';
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the Name of Printer on shipmondo';
                    ApplicationArea = NPRRetail;
                }
                field("Host Name"; Rec."Host Name")
                {

                    ToolTip = 'Specifies the Host Name of Server';
                    ApplicationArea = NPRRetail;
                }
                field(Printer; Rec.Printer)
                {

                    ToolTip = 'Specifies the Name of Printer on server';
                    ApplicationArea = NPRRetail;
                }
                field("Label Format"; Rec."Label Format")
                {

                    ToolTip = 'Specifies the Label format from external shipping service';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies Location for which Printer to use';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the User that will use the Corresponding Printer';
                    ApplicationArea = NPRRetail;
                }
                field("User Name"; Rec."User Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the User Name that will use the Corresponding Printer';
                    ApplicationArea = NPRRetail;
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

                Image = PrintCover;
                ToolTip = 'Executes the Get printers action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ShipmondoMgnt: Codeunit "NPR Shipmondo Mgnt.";
                begin
                    ShipmondoMgnt.GetPrinters(1, false);
                end;
            }
        }
    }
}

