page 6014514 "Warranty Catalog"
{
    // 
    // // 3.0j ved Nicolai Esbensen
    //   Tilf¢jet kommentar relation.
    // 
    // NPR5.23/TS/20160518  CASE 240748  Renamed Page and Added Actions
    // NPR5.41/TS  /20180105 CASE 300893 Removed Action History as Page 6014591 does not exist.

    Caption = 'Warranty';
    SourceTable = "Warranty Directory";

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
                        }
                        field(Description; Description)
                        {
                            ApplicationArea = All;
                        }
                        field(Name; Name)
                        {
                            ApplicationArea = All;
                        }
                        field("Salesperson Code"; "Salesperson Code")
                        {
                            ApplicationArea = All;
                        }
                        field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                        {
                            ApplicationArea = All;
                        }
                        field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        field(Bonnummer; Bonnummer)
                        {
                            ApplicationArea = All;
                        }
                        field(Kassenummer; Kassenummer)
                        {
                            ApplicationArea = All;
                        }
                        field(Debitortype; Debitortype)
                        {
                            ApplicationArea = All;
                        }
                        field("Customer No."; "Customer No.")
                        {
                            ApplicationArea = All;
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
                                }
                                field("Police 2"; "Police 2")
                                {
                                    ApplicationArea = All;
                                }
                                field("Police 3"; "Police 3")
                                {
                                    ApplicationArea = All;
                                }
                                field("Police udstedt"; "Police udstedt")
                                {
                                    ApplicationArea = All;
                                }
                                field("Insurance Sent"; "Insurance Sent")
                                {
                                    ApplicationArea = All;
                                }
                                field("Delivery Date"; "Delivery Date")
                                {
                                    ApplicationArea = All;
                                }
                            }
                            group("Expiry Date")
                            {
                                Caption = 'Expiry Date';
                                field("Police 1 End Date"; "Police 1 End Date")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                }
                                field("Police 2 udstedt"; "Police 2 udstedt")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                }
                                field("Police 3 udstedt"; "Police 3 udstedt")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                }
                            }
                            group(Amount)
                            {
                                Caption = 'Amount';
                                field("Premium 1"; "Premium 1")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                }
                                field("Premium 2"; "Premium 2")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
                                }
                                field("Premium 3"; "Premium 3")
                                {
                                    ApplicationArea = All;
                                    ShowCaption = false;
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
                        }
                        field("Name 2"; "Name 2")
                        {
                            ApplicationArea = All;
                        }
                        field(Address; Address)
                        {
                            ApplicationArea = All;
                        }
                        field("Address 2"; "Address 2")
                        {
                            ApplicationArea = All;
                        }
                        field(City; City)
                        {
                            ApplicationArea = All;
                        }
                        field("Post Code"; "Post Code")
                        {
                            ApplicationArea = All;
                        }
                        field("Phone No."; "Phone No.")
                        {
                            ApplicationArea = All;
                        }
                        field("E-Mail"; "E-Mail")
                        {
                            ApplicationArea = All;
                        }
                        field("Phone No. 2"; "Phone No. 2")
                        {
                            ApplicationArea = All;
                        }
                        field("Fax No."; "Fax No.")
                        {
                            ApplicationArea = All;
                        }
                        field("Your Reference"; "Your Reference")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(Control6150658)
                    {
                        ShowCaption = false;
                        field("Bill-to Customer No."; "Bill-to Customer No.")
                        {
                            ApplicationArea = All;
                        }
                        field("Bill-to Name"; "Bill-to Name")
                        {
                            ApplicationArea = All;
                        }
                        field("Bill-to Address"; "Bill-to Address")
                        {
                            ApplicationArea = All;
                        }
                        field("Bill-to Address 2"; "Bill-to Address 2")
                        {
                            ApplicationArea = All;
                        }
                        field("Bill-to City"; "Bill-to City")
                        {
                            ApplicationArea = All;
                        }
                        field("Bill-to Contact"; "Bill-to Contact")
                        {
                            ApplicationArea = All;
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
                        }
                        field("2. Service Incoming"; "2. Service Incoming")
                        {
                            ApplicationArea = All;
                        }
                        field("3. Service Incoming"; "3. Service Incoming")
                        {
                            ApplicationArea = All;
                        }
                        field("4. Service Incoming"; "4. Service Incoming")
                        {
                            ApplicationArea = All;
                        }
                        field("5. Service Incoming"; "5. Service Incoming")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(Control6150674)
                    {
                        ShowCaption = false;
                        field("1. Service Done"; "1. Service Done")
                        {
                            ApplicationArea = All;
                        }
                        field("2. Service Done"; "2. Service Done")
                        {
                            ApplicationArea = All;
                        }
                        field("3. Service Done"; "3. Service Done")
                        {
                            ApplicationArea = All;
                        }
                        field("4. Service Done"; "4. Service Done")
                        {
                            ApplicationArea = All;
                        }
                        field("5. Service Done"; "5. Service Done")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
            part(Control6150680; "Warranty Cat. Lines")
            {
                SubPageLink = "Warranty No." = FIELD("No.");
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
                    RunObject = Page "Warranty Catalog List";
                    ShortCutKey = 'F5';
                }
                action("Calculate Premium")
                {
                    Caption = 'Calculate premium';
                    Image = Calculate;

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

                    trigger OnAction()
                    var
                        GarantiHoved: Record "Warranty Directory";
                    begin

                        CurrPage.SetSelectionFilter(GarantiHoved);
                        GarantiHoved.PrintRec(false);
                    end;
                }
                action(Policy)
                {
                    Caption = 'Policy';
                    Image = "Action";

                    trigger OnAction()
                    var
                        GarantiHoved: Record "Warranty Directory";
                    begin

                        CurrPage.SetSelectionFilter(GarantiHoved);
                        GarantiHoved.PrintPolicy;
                    end;
                }
                action("Insurance Offer")
                {
                    Caption = 'Insurance Offer';
                    Image = Insurance;

                    trigger OnAction()
                    var
                        FotoCode: Codeunit "Retail Contract Mgt.";
                    begin

                        FotoCode.PrintInsurance(Kassenummer, Bonnummer, true);
                    end;
                }
            }
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;

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

