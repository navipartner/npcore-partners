page 6014532 "Touch Screen - Saved sales"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.14/RMT/20150812 CASE 219870 Set page options
    //                                  ModifyAllowed = No
    //                                  InsertAllowed = No
    //                                  DelayedInsert = No
    // NPR4.15/LS/20150930  CASE 224013 : Added Date and Start Time fields
    // NPR5.00/VB/20160107 CASE 230400 Changed dialog type to support select+click functionality.
    // NPR5.22/MMV/20160408 CASE 232067 Added field "Customer Location No."
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.37/TS  /20171012  CASE 292422  Changing properties to Additional on field "Customer Location No."
    // NPR5.39/TJ  /20180208  CASE 302634  Renamed parameters of function init to english

    Caption = 'Touch Screen - Select sales';
    DelayedInsert = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "Sale POS";
    SourceTableView = SORTING("Salesperson Code","Saved Sale")
                      WHERE("Saved Sale"=CONST(true));

    layout
    {
        area(content)
        {
            repeater(Control6150615)
            {
                ShowCaption = false;
                Visible = NOT ReturnSale;
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field(Date;Date)
                {
                }
                field("Start Time";"Start Time")
                {
                }
                field("Customer Location No.";"Customer Location No.")
                {
                    Importance = Additional;
                }
                field("Customer Name";"Customer Name")
                {
                }
            }
            group(Control6150620)
            {
                ShowCaption = false;
                part("Sales Lines";"Sale POS - Saved Sale Line")
                {
                    Caption = 'Sales Lines';
                    SubPageLink = "Sales Ticket No."=FIELD("Sales Ticket No.");
                    SubPageView = SORTING("Register No.","Sales Ticket No.","Sale Type","Line No.")
                                  ORDER(Ascending)
                                  WHERE(Type=FILTER(<>Payment));
                }
                part("Payment Lines";"Sale POS - Saved Sale Line")
                {
                    Caption = 'Payment Lines';
                    SubPageLink = "Sales Ticket No."=FIELD("Sales Ticket No.");
                    SubPageView = SORTING("Register No.","Sales Ticket No.","Sale Type","Line No.")
                                  ORDER(Ascending)
                                  WHERE(Type=CONST(Payment));
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Load Saved Sale")
            {
                Caption = 'Load Sale';
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                Visible = NOT HideFetchButton;

                trigger OnAction()
                var
                    TouchForm: Page "Touch Screen - Sale (Web)";
                begin
                    //-259086
                    // //-NPR4.10
                    // //TouchForm.SetSavedSale(Rec);
                    // //TouchForm.RUN();
                    // IF SessionMgt.IsDotNet() THEN BEGIN
                    //  TouchForm.SetSavedSale(Rec);
                    //  TouchForm.RUN();
                    // END ELSE BEGIN
                    //  TouchFormWeb.SetSavedSale(Rec);
                    //  TouchFormWeb.RUN();
                    // END;
                    // //+NPR4.10
                    TouchForm.SetSavedSale(Rec);
                    TouchForm.Run();
                    //+259086
                end;
            }
        }
    }

    var
        "NP Konfig": Record "Retail Setup";
        FormCode: Codeunit "Retail Form Code";
        ReturnSale: Boolean;
        HideFetchButton: Boolean;

    procedure init(RegisterNo: Code[10];SalespersonCode: Code[10])
    begin
    end;

    procedure hide(b: Boolean)
    begin
        ReturnSale := b;
    end;

    procedure DisableFetchButton()
    begin
        HideFetchButton := true;
    end;
}

