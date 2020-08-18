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
                        field("No.";"No.")
                        {
                        }
                        field(Description;Description)
                        {
                        }
                        field(Name;Name)
                        {
                        }
                        field("Salesperson Code";"Salesperson Code")
                        {
                        }
                        field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                        {
                        }
                        field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                        {
                        }
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        field(Bonnummer;Bonnummer)
                        {
                        }
                        field(Kassenummer;Kassenummer)
                        {
                        }
                        field(Debitortype;Debitortype)
                        {
                        }
                        field("Customer No.";"Customer No.")
                        {
                        }
                        grid(Control6150629)
                        {
                            ShowCaption = false;
                            group("Police No.")
                            {
                                Caption = 'Police No.';
                                field("Police 1";"Police 1")
                                {
                                }
                                field("Police 2";"Police 2")
                                {
                                }
                                field("Police 3";"Police 3")
                                {
                                }
                                field("Police udstedt";"Police udstedt")
                                {
                                }
                                field("Insurance Sent";"Insurance Sent")
                                {
                                }
                                field("Delivery Date";"Delivery Date")
                                {
                                }
                            }
                            group("Expiry Date")
                            {
                                Caption = 'Expiry Date';
                                field("Police 1 End Date";"Police 1 End Date")
                                {
                                    ShowCaption = false;
                                }
                                field("Police 2 udstedt";"Police 2 udstedt")
                                {
                                    ShowCaption = false;
                                }
                                field("Police 3 udstedt";"Police 3 udstedt")
                                {
                                    ShowCaption = false;
                                }
                            }
                            group(Amount)
                            {
                                Caption = 'Amount';
                                field("Premium 1";"Premium 1")
                                {
                                    ShowCaption = false;
                                }
                                field("Premium 2";"Premium 2")
                                {
                                    ShowCaption = false;
                                }
                                field("Premium 3";"Premium 3")
                                {
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
                        field(Name1;Name)
                        {
                        }
                        field("Name 2";"Name 2")
                        {
                        }
                        field(Address;Address)
                        {
                        }
                        field("Address 2";"Address 2")
                        {
                        }
                        field(City;City)
                        {
                        }
                        field("Post Code";"Post Code")
                        {
                        }
                        field("Phone No.";"Phone No.")
                        {
                        }
                        field("E-Mail";"E-Mail")
                        {
                        }
                        field("Phone No. 2";"Phone No. 2")
                        {
                        }
                        field("Fax No.";"Fax No.")
                        {
                        }
                        field("Your Reference";"Your Reference")
                        {
                        }
                    }
                    group(Control6150658)
                    {
                        ShowCaption = false;
                        field("Bill-to Customer No.";"Bill-to Customer No.")
                        {
                        }
                        field("Bill-to Name";"Bill-to Name")
                        {
                        }
                        field("Bill-to Address";"Bill-to Address")
                        {
                        }
                        field("Bill-to Address 2";"Bill-to Address 2")
                        {
                        }
                        field("Bill-to City";"Bill-to City")
                        {
                        }
                        field("Bill-to Contact";"Bill-to Contact")
                        {
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
                        field("1. Service Incoming";"1. Service Incoming")
                        {
                        }
                        field("2. Service Incoming";"2. Service Incoming")
                        {
                        }
                        field("3. Service Incoming";"3. Service Incoming")
                        {
                        }
                        field("4. Service Incoming";"4. Service Incoming")
                        {
                        }
                        field("5. Service Incoming";"5. Service Incoming")
                        {
                        }
                    }
                    group(Control6150674)
                    {
                        ShowCaption = false;
                        field("1. Service Done";"1. Service Done")
                        {
                        }
                        field("2. Service Done";"2. Service Done")
                        {
                        }
                        field("3. Service Done";"3. Service Done")
                        {
                        }
                        field("4. Service Done";"4. Service Done")
                        {
                        }
                        field("5. Service Done";"5. Service Done")
                        {
                        }
                    }
                }
            }
            part(Control6150680;"Warranty Cat. Lines")
            {
                SubPageLink = "Warranty No."=FIELD("No.");
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

                        CurrPage.SetSelectionFilter( GarantiHoved );
                        GarantiHoved.PrintRec( false );
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

                        CurrPage.SetSelectionFilter( GarantiHoved );
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

                        FotoCode.PrintInsurance( Kassenummer, Bonnummer, true );
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

        if Rec.Find('+') then ;
    end;
}

