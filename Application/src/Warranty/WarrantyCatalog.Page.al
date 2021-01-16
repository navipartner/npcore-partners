page 6014514 "NPR Warranty Catalog"
{
    // 
    // // 3.0j ved Nicolai Esbensen
    //   Tilf¢jet kommentar relation.
    // 
    // NPR5.23/TS/20160518  CASE 240748  Renamed Page and Added Actions
    // NPR5.41/TS  /20180105 CASE 300893 Removed Action History as Page 6014591 does not exist.

    UsageCategory = None;
    Caption = 'Warranty';
    SourceTable = "NPR Warranty Directory";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                grid(Control6150615)
                {
                    ShowCaption = false;
                    group(Control6150616)
                    {
                        ShowCaption = false;
                        field("No."; "No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the No. field';
                        }
                        field(Description; Description)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Description field';
                        }
                        field(Name; Name)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Name field';
                        }
                        field("Salesperson Code"; "Salesperson Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Salesperson Code field';
                        }
                        field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                        }
                        field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                        }
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        field(Bonnummer; Bonnummer)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Ticket No. field';
                        }
                        field(Kassenummer; Kassenummer)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Register No. field';
                        }
                        field(Debitortype; Debitortype)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Debit Type field';
                        }
                        field("Customer No."; "Customer No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Customer No. field';
                        }
                        grid(Control6150629)
                        {
                            ShowCaption = false;
                            group("Police No.")
                            {
                                Caption = 'Police No.';
                                field("Police 1"; "Police 1")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the Police 1 field';
                                }
                                field("Police 2"; "Police 2")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the Police 2 field';
                                }
                                field("Police 3"; "Police 3")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the Police 3 field';
                                }
                                field("Police udstedt"; "Police udstedt")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the Police Issued field';
                                }
                                field("Insurance Sent"; "Insurance Sent")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the Insurance send field';
                                }
                                field("Delivery Date"; "Delivery Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the Delivery Date field';
                                }
                            }
                            group("Expiry Date")
                            {
                                Caption = 'Expiry Date';
                                field("Police 1 End Date"; "Police 1 End Date")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the value of the Police 1 expiry date field';
                                }
                                field("Police 2 udstedt"; "Police 2 udstedt")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the value of the Police 2 issued field';
                                }
                                field("Police 3 udstedt"; "Police 3 udstedt")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the value of the Police 3 issued field';
                                }
                            }
                            group(Amount)
                            {
                                Caption = 'Amount';
                                field("Premium 1"; "Premium 1")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the value of the Insurance Amount 1 field';
                                }
                                field("Premium 2"; "Premium 2")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the value of the Insurance Amount 2 field';
                                }
                                field("Premium 3"; "Premium 3")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the value of the Insurance Amount 3 field';
                                }
                            }
                        }
                    }
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                grid(Control6150656)
                {
                    ShowCaption = false;
                    group(Control6150657)
                    {
                        ShowCaption = false;
                        field(Name1; Name)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Name field';
                        }
                        field("Name 2"; "Name 2")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Name 2 field';
                        }
                        field(Address; Address)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Address field';
                        }
                        field("Address 2"; "Address 2")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Address 2 field';
                        }
                        field(City; City)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the City field';
                        }
                        field("Post Code"; "Post Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Post Code field';
                        }
                        field("Phone No."; "Phone No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Phone No. field';
                        }
                        field("E-Mail"; "E-Mail")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the E-Mail field';
                        }
                        field("Phone No. 2"; "Phone No. 2")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Phone No. 2 field';
                        }
                        field("Fax No."; "Fax No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Fax No. field';
                        }
                        field("Your Reference"; "Your Reference")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Your Reference field';
                        }
                    }
                    group(Control6150658)
                    {
                        ShowCaption = false;
                        field("Bill-to Customer No."; "Bill-to Customer No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                        }
                        field("Bill-to Name"; "Bill-to Name")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Bill-to Name field';
                        }
                        field("Bill-to Address"; "Bill-to Address")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Bill-to Address field';
                        }
                        field("Bill-to Address 2"; "Bill-to Address 2")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Bill-to Address 2 field';
                        }
                        field("Bill-to City"; "Bill-to City")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Bill-to City field';
                        }
                        field("Bill-to Contact"; "Bill-to Contact")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Bill-to Contact field';
                        }
                    }
                }
            }
            group(Service)
            {
                Caption = 'Service';
                grid(Control6150672)
                {
                    ShowCaption = false;
                    group(Control6150673)
                    {
                        ShowCaption = false;
                        field("1. Service Incoming"; "1. Service Incoming")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 1. Service Incoming field';
                        }
                        field("2. Service Incoming"; "2. Service Incoming")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 2. Service Incoming field';
                        }
                        field("3. Service Incoming"; "3. Service Incoming")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 3. Service Incoming field';
                        }
                        field("4. Service Incoming"; "4. Service Incoming")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 4. Service Incoming field';
                        }
                        field("5. Service Incoming"; "5. Service Incoming")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 5. Service Incoming field';
                        }
                    }
                    group(Control6150674)
                    {
                        ShowCaption = false;
                        field("1. Service Done"; "1. Service Done")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 1. Service Done field';
                        }
                        field("2. Service Done"; "2. Service Done")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 2. Service Done field';
                        }
                        field("3. Service Done"; "3. Service Done")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 3. Service Done field';
                        }
                        field("4. Service Done"; "4. Service Done")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 4. Service Done field';
                        }
                        field("5. Service Done"; "5. Service Done")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 5. Service Done field';
                        }
                    }
                }
            }
            part(Control6150680; "NPR Warranty Cat. Lines")
            {
                SubPageLink = "Warranty No." = FIELD("No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Function';
                action(List)
                {
                    Caption = 'List';
                    Image = List;
                    RunObject = Page "NPR Warranty Catalog List";
                    ShortCutKey = 'F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the List action';
                }
                action("Calculate Premium")
                {
                    Caption = 'Calculate premium';
                    Image = Calculate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Calculate premium action';

                    trigger OnAction()
                    begin
                        UpdatePremium();
                    end;
                }
            }
            group(Print)
            {
                Caption = '&Print';
                action(Warranty)
                {
                    Caption = 'Warranty';
                    Image = WarrantyLedger;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Warranty action';

                    trigger OnAction()
                    var
                        GarantiHoved: Record "NPR Warranty Directory";
                    begin

                        CurrPage.SetSelectionFilter(GarantiHoved);
                        GarantiHoved.PrintRec(false);
                    end;
                }
                action(Policy)
                {
                    Caption = 'Policy';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Policy action';

                    trigger OnAction()
                    var
                        GarantiHoved: Record "NPR Warranty Directory";
                    begin

                        CurrPage.SetSelectionFilter(GarantiHoved);
                        GarantiHoved.PrintPolicy;
                    end;
                }
                action("Insurance Offer")
                {
                    Caption = 'Insurance Offer';
                    Image = Insurance;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Insurance Offer action';

                    trigger OnAction()
                    var
                        FotoCode: Codeunit "NPR Retail Contract Mgt.";
                    begin

                        FotoCode.PrintInsurance(Kassenummer, Bonnummer, true);
                    end;
                }
            }
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

                trigger OnAction()
                begin

                    Navigate;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin


        if ("Insurance Sent" <> 0D) then
            CurrPage.Editable(false)
        else
            CurrPage.Editable(true);
    end;

    trigger OnOpenPage()
    begin

        if Rec.Find('+') then;
    end;
}

