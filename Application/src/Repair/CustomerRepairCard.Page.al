page 6014503 "NPR Customer Repair Card"
{
    UsageCategory = None;
    Caption = 'Customer Repair Card';
    PromotedActionCategories = 'New,Process,Reports,Pictures,Tasks';
    SourceTable = "NPR Customer Repair";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Customer Type"; "Customer Type")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Type';
                    ToolTip = 'Specifies the value of the Customer Type field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';

                    trigger OnDrillDown()
                    begin
                        if "Customer No." <> '' then begin
                            CustLedgerEntry.Reset;
                            CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", "Customer No.");
                            PAGE.RunModal(PAGE::"Customer Ledger Entries", CustLedgerEntry)
                        end;
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
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
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Contact Person"; "Contact Person")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Person field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                }
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the E-mail field';
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field';
                }
                field("Bag No"; "Bag No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bag No field';
                }
                field("Contact after"; "Contact after")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact After field';
                }
                field("Delivery reff."; "Delivery reff.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Reff. field';
                }
                field(Finalized; Finalized)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Finalized field';
                }
            }
            group("Repairer Details")
            {
                Caption = 'Repairer Details';
                field("In-house Repairer"; "In-house Repairer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the In-house Repairer field';

                    trigger OnValidate()
                    begin
                        //-NPR5.27
                        SetOwnRepair();
                        CurrPage.Update;
                        //+NPR5.27
                    end;
                }
                field("Repairer No."; "Repairer No.")
                {
                    ApplicationArea = All;
                    Enabled = RepairedNoEnabled;
                    ToolTip = 'Specifies the value of the Repairer No. field';
                }
                field("Repairer Name"; "Repairer Name")
                {
                    ApplicationArea = All;
                    Enabled = RepairNameEnabled;
                    ToolTip = 'Specifies the value of the Repairer Name field';
                }
                field("Repairer Address"; "Repairer Address")
                {
                    ApplicationArea = All;
                    Enabled = RepairAddressEnabled;
                    ToolTip = 'Specifies the value of the Repairer Address field';
                }
                field("Repairer Address2"; "Repairer Address2")
                {
                    ApplicationArea = All;
                    Enabled = RepairAddress2Enabled;
                    ToolTip = 'Specifies the value of the Repairer Address2 field';
                }
                field("Repairer Post Code"; "Repairer Post Code")
                {
                    ApplicationArea = All;
                    Enabled = RepairPostCodeEnabled;
                    ToolTip = 'Specifies the value of the Repairer Post Code field';
                }
                field("Repairer City"; "Repairer City")
                {
                    ApplicationArea = All;
                    Enabled = RepairCityEnabled;
                    ToolTip = 'Specifies the value of the Repairer City field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
            }
            group(Registration)
            {
                Caption = 'Registration';
                group(Control6150643)
                {
                    ShowCaption = false;
                    field("Item No."; "Item No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Item No. field';
                    }
                    field("Item Description"; "Item Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Description field';
                    }
                    field("Unit Cost"; "Unit Cost")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Cost field';
                    }
                    field("Variant Code"; "Variant Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Variant code';
                        ToolTip = 'Specifies the value of the Variant code field';
                    }
                    field(Worranty; Worranty)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Guarantee field';

                        trigger OnValidate()
                        begin
                            WarantyTextEnabled := Worranty;
                        end;
                    }
                    field("Warranty Text"; "Warranty Text")
                    {
                        ApplicationArea = All;
                        Enabled = WarantyTextEnabled;
                        ToolTip = 'Specifies the value of the Warranty Text field';
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field';
                    }
                    field(Brand; Brand)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Brand field';
                    }
                    field("Serial No."; "Serial No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Serial No. field';
                    }
                    field("Alt. Serial No."; "Alt. Serial No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Alt. Serial No. field';
                    }
                    field(Accessories; Accessories)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Accessories field';
                    }
                    field("Accessories 1"; "Accessories 1")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Accessories 1 field';
                    }
                    field("Costs Paid by Offer"; "Costs Paid by Offer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Costs Paid by Offer field';
                    }
                }
                group(Control6150658)
                {
                    ShowCaption = false;
                    field("Prices Including VAT"; "Prices Including VAT")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Prices Including VAT field';
                    }
                    field("To Ship"; "To Ship")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the To Ship field';
                    }
                    field("Handed In Date"; "Handed In Date")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Handed In Date field';
                    }
                    field("Expected Completion Date"; "Expected Completion Date")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Expected Completion Date field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                    field("Date Delivered"; "Date Delivered")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Date Delivered field';
                    }
                    field("Delivering Salespers."; "Delivering Salespers.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Delivering Salespers. field';
                    }
                    field("Delivering Sales Ticket No."; "Delivering Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivering Sales Ticket No. field';
                    }
                }
            }
            group("Invoiced To")
            {
                Caption = 'Invoiced To';
                group(Control6150670)
                {
                    ShowCaption = false;
                    field("Invoice To"; "Invoice To")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Invoice To field';
                    }
                    field("Customer Name"; "Customer Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Name field';
                    }
                    field("Customer Address"; "Customer Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Address field';
                    }
                    field("Customer Address 2"; "Customer Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Address 2 field';
                    }
                    field("Customer Post Code"; "Customer Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Post Code field';
                    }
                    field("Customer City"; "Customer City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer City field';
                    }
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                group(Control6150642)
                {
                    ShowCaption = false;
                    field("Price when Not Accepted"; "Price when Not Accepted")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Price when Not Accepted field';
                    }
                    field(Delivered; Delivered)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivered field';
                    }
                    field("Service nr."; "Service nr.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service No. field';
                    }
                    field(Type; Type)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Type field';
                    }
                    field("Customer Answer"; "Customer Answer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Answer field';
                    }
                }
                group(Control6150685)
                {
                    ShowCaption = false;
                    field("Requested Returned, No Repair"; "Requested Returned, No Repair")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Requested Returned, No Repair field';
                    }
                    field("Approved by repairer"; "Approved by repairer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Approved by Repairer field';
                    }
                    field("Return from Repair"; "Return from Repair")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Return from Repair field';
                    }
                    field(Claimed; Claimed)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claimed field';
                    }
                    field("Offer Sent"; "Offer Sent")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Offer Sent field';
                    }
                    field("Reported Ready and Sent"; "Reported Ready and Sent")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reported Ready and Sent field';
                    }
                }
            }
            group("Defect Description")
            {
                Caption = 'Defect Description';
                part(vv; "NPR Customer Repair Journal")
                {
                    SubPageLink = "Customer Repair No." = FIELD("No."),
                                  Type = CONST(Fejlbeskrivelse);
                    ApplicationArea = All;
                }
            }
            group("Repair Description")
            {
                Caption = 'Repair Description';
                part(CustomerRepairJournal; "NPR Customer Repair Journal")
                {
                    SubPageLink = "Customer Repair No." = FIELD("No."),
                                  Type = CONST(Reparationsbeskrivelse);
                    ApplicationArea = All;
                }
            }
            group(Picture)
            {
                Caption = 'Picture';
                field("Picture Documentation1"; "Picture Documentation1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture Documentation1 field';
                }
                field("Picture Documentation2"; "Picture Documentation2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture Documentation2 field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014416; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                Caption = '&Print';
                action("Repair Label")
                {
                    Caption = 'Repair Label';
                    Image = BinContent;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Repair Label action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                        MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
                        RecRef: RecordRef;
                        RecID: RecordID;
                    begin
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair Label");
                        if ReportSelectionContract.FindFirst then begin
                            RecRef.Open(DATABASE::"NPR Customer Repair");
                            RecID := Rec.RecordId;
                            RecRef.Get(RecID);
                            RecRef.SetRecFilter;
                            if ReportSelectionContract."Codeunit ID" = CODEUNIT::"NPR RP Matrix Print Mgt." then
                                MatrixPrintMgt.ProcessTemplate(ReportSelectionContract."Print Template", RecRef);
                        end;
                    end;
                }
                action("&Repair Offer")
                {
                    Caption = '&Repair Offer';
                    Image = "Report";
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Repair Offer action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;

                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair offer");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", Register);
                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');

                        if ReportSelectionContract.FindSet then begin
                            repeat
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, false, CustomerRepairGlobal);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                    end;
                }
                action("Repair Do&ne")
                {
                    Caption = 'Repair Do&ne';
                    Image = "Report";
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Repair Do&ne action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair finished");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", Register);

                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');

                        if ReportSelectionContract.FindSet then begin
                            repeat
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, false, CustomerRepairGlobal);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                    end;
                }
                action("Repair &Guarantee")
                {
                    Caption = 'Repair &Guarantee';
                    Image = "Report";
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Repair &Guarantee action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair warranty");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", Register);

                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');

                        if ReportSelectionContract.FindSet then begin
                            repeat
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, false, CustomerRepairGlobal);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                    end;
                }
                action(Customernote)
                {
                    Caption = 'Customernote';
                    Image = "Report";
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customernote action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Customer receipt");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", Register);
                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');

                        if ReportSelectionContract.FindSet then begin
                            repeat
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", false, false, CustomerRepairGlobal);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                    end;
                }
                action("De&livery Note")
                {
                    Caption = 'De&livery Note';
                    Image = "Report";
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the De&livery Note action';

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Shipment note");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", Register);
                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');
                        if ReportSelectionContract.FindSet then begin
                            repeat
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", false, false, CustomerRepairGlobal);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                    end;
                }
            }
            group("Pic&ture")
            {
                Caption = 'Pic&ture';
                group("Picturedoc.&1")
                {
                    Caption = 'Picturedoc.&1';
                    Image = Setup;
                    action("&Input")
                    {
                        Caption = '&Input';
                        Image = Import;
                        Promoted = true;
				        PromotedOnly = true;
                        PromotedCategory = Category4;
                        ApplicationArea = All;
                        ToolTip = 'Executes the &Input action';

                        trigger OnAction()
                        var
                            RecRef: RecordRef;
                        begin
                            ImageFound := "Picture Documentation1".HasValue;
                            Clear(TempBlob);
                            "Picture Path 1" := FileManagement.BLOBImport(TempBlob, TextName);
                            RecRef.GetTable(Rec);
                            TempBlob.ToRecordRef(RecRef, FieldNo("Picture Documentation1"));
                            RecRef.SetTable(Rec);
                            if "Picture Path 1" = '' then
                                exit;
                            if ImageFound then
                                if not Confirm(Text10600001, false) then
                                    exit;
                            CurrPage.SaveRecord;
                        end;
                    }
                    action("O&utput")
                    {
                        Caption = 'O&utput';
                        Image = Export;
                        Promoted = true;
				        PromotedOnly = true;
                        PromotedCategory = Category4;
                        ApplicationArea = All;
                        ToolTip = 'Executes the O&utput action';

                        trigger OnAction()
                        var
                            CustomerRepair: Record "NPR Customer Repair";
                        begin
                            Clear(TempBlob);
                            CustomerRepair.SetRange("No.", "No.");
                            if CustomerRepair.FindFirst then begin
                                CustomerRepair.CalcFields("Picture Documentation1");
                                TempBlob.FromRecord(CustomerRepair, CustomerRepair.FieldNo("Picture Documentation1"));
                                if CustomerRepair."Picture Documentation1".HasValue then
                                    FileManagement.BLOBExport(TempBlob, CustomerRepair."Picture Path 1", true);
                            end;
                        end;
                    }
                    action("&Delete")
                    {
                        Caption = '&Delete';
                        Image = Delete;
                        Promoted = true;
				        PromotedOnly = true;
                        PromotedCategory = Category4;
                        ApplicationArea = All;
                        ToolTip = 'Executes the &Delete action';

                        trigger OnAction()
                        begin
                            if "Picture Documentation1".HasValue then
                                if Confirm(Text10600002, false) then begin
                                    Clear("Picture Documentation1");
                                    CurrPage.SaveRecord;
                                end;
                        end;
                    }
                }
                group("Picturedoc.&2")
                {
                    Caption = 'Picturedoc.&2';
                    Image = Setup;
                    action(Action6150717)
                    {
                        Caption = 'O&utput';
                        Image = Export;
                        Promoted = true;
				        PromotedOnly = true;
                        PromotedCategory = Category4;
                        ApplicationArea = All;
                        ToolTip = 'Executes the O&utput action';

                        trigger OnAction()
                        var
                            CustomerRepair: Record "NPR Customer Repair";
                        begin
                            Clear(TempBlob);
                            CustomerRepair.SetRange("No.", "No.");
                            if CustomerRepair.FindFirst then begin
                                CustomerRepair.CalcFields("Picture Documentation2");
                                TempBlob.FromRecord(CustomerRepair, CustomerRepair.FieldNo("Picture Documentation2"));
                                if CustomerRepair."Picture Documentation2".HasValue then
                                    FileManagement.BLOBExport(TempBlob, CustomerRepair."Picture Path 2", true);
                            end;
                        end;
                    }
                }
            }
            separator(Separator6014404)
            {
            }
            group("R&epair")
            {
                Caption = 'R&epair';
                action(List)
                {
                    Caption = 'List';
                    Image = List;
                    RunObject = Page "NPR Customer Repair List";
                    RunPageView = WHERE(Status = FILTER(<> Claimed));
                    ShortCutKey = 'F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the List action';
                }
                action("Repair Closed/Claimed List")
                {
                    Caption = 'Repair Closed/Claimed List';
                    Image = List;
                    RunObject = Page "NPR Customer Repair List";
                    RunPageView = WHERE(Status = FILTER(Claimed));
                    ShortCutKey = 'F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Repair Closed/Claimed List action';
                }
                action("Finalize Repair")
                {
                    Caption = 'Finalize Repair';
                    Image = Close;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Finalize Repair action';

                    trigger OnAction()
                    begin
                        if Confirm(Text10600004, true) then
                            PostItemPart(Rec);
                    end;
                }
                action("Post Items")
                {
                    Caption = 'Post Items';
                    Image = Post;
                    Promoted = true;
				    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post Items action';

                    trigger OnAction()
                    begin
                        PostItemPartWithoutFinalize(Rec);
                    end;
                }
                action("Finalize Repair and Print")
                {
                    Caption = 'Finalize Repair and Print';
                    Image = Close;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Finalize Repair and Print action';

                    trigger OnAction()
                    begin
                        if Confirm(Text10600005, true) then begin
                            PostItemPart(Rec);
                            SetRecFilter;
                            if xRec.Finalized = false then
                                REPORT.RunModal(6014502, false, true, Rec);
                        end;
                    end;
                }
                action("Send Status Sms")
                {
                    Caption = 'Send Status Sms';
                    Image = SendElectronicDocument;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Status Sms action';

                    trigger OnAction()
                    var
                        RetailContractMgt: Codeunit "NPR Retail Contract Mgt.";
                    begin
                        RetailContractMgt.SendStatusSms(Rec);
                    end;
                }
                action("Send Custom Sms")
                {
                    Caption = 'Send Custom Sms';
                    Image = SendTo;
                    RunObject = Page "NPR Send SMS";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Custom Sms action';
                }
                action("Create Invoice")
                {
                    Caption = 'Create Invoice';
                    Image = CreateDocument;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Invoice action';

                    trigger OnAction()
                    begin
                        CreateSalesDocument(Enum::"Sales Document Type"::Invoice);
                    end;
                }
                action("Create Sales Order")
                {
                    Caption = 'Create Sales Order';
                    Image = CreateDocument;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Sales Order action';

                    trigger OnAction()
                    begin
                        CreateSalesDocument(Enum::"Sales Document Type"::"Order");
                    end;
                }
            }
            group("Send Mails")
            {
                Caption = 'Send Mails';
                action("Email Repair Offer")
                {
                    Caption = 'Email Repair Offer';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Email Repair Offer action';

                    trigger OnAction()
                    var
                        CustomerRepair: Record "NPR Customer Repair";
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepair := Rec;
                        CustomerRepair.SetRecFilter;

                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair offer");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", "Register No.");
                        if ReportSelectionContract.FindFirst then begin
                            repeat
                                SendMail(ReportSelectionContract."Report ID", CustomerRepair);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                        Message(EmailSent);
                    end;
                }
                action("Email Repair Done")
                {
                    Caption = 'Email Repair Done';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Email Repair Done action';

                    trigger OnAction()
                    var
                        CustomerRepair: Record "NPR Customer Repair";
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepair := Rec;
                        CustomerRepair.SetRecFilter;

                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair finished");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", "Register No.");
                        if ReportSelectionContract.FindFirst then begin
                            repeat
                                SendMail(ReportSelectionContract."Report ID", CustomerRepair);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                        Message(EmailSent);
                    end;
                }
                action("Email Repair Guarantee")
                {
                    Caption = 'Email Repair Guarantee';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Email Repair Guarantee action';

                    trigger OnAction()
                    var
                        CustomerRepair: Record "NPR Customer Repair";
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        CustomerRepair := Rec;
                        CustomerRepair.SetRecFilter;

                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair warranty");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", "Register No.");
                        if ReportSelectionContract.FindFirst then begin
                            repeat
                                SendMail(ReportSelectionContract."Report ID", CustomerRepair);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                        Message(EmailSent);
                    end;
                }
                action("Email Customer Note")
                {
                    Caption = 'Email Customer Note';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Email Customer Note action';

                    trigger OnAction()
                    var
                        CustomerRepair: Record "NPR Customer Repair";
                        ReportSelectionContract: Record "NPR Report Selection: Contract";
                    begin
                        //-NPR5.27
                        CustomerRepair := Rec;
                        CustomerRepair.SetRecFilter;
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Customer receipt");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        ReportSelectionContract.SetRange("Register No.", "Register No.");
                        if ReportSelectionContract.FindFirst then begin
                            repeat
                                SendMail(ReportSelectionContract."Report ID", CustomerRepair);
                            until ReportSelectionContract.Next = 0;
                        end else begin
                            Error(ErrNoReportFound,
                                  ReportSelectionContract.FieldCaption("Report Type"),
                                  ReportSelectionContract.TableCaption);
                        end;
                        Message(EmailSent);
                        //+NPR5.27
                    end;
                }
            }
            group(ActionGroup6150724)
            {
                action(Navigate)
                {
                    Caption = '&Navigate';
                    Image = Navigate;
                    Promoted = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Navigate action';

                    trigger OnAction()
                    begin
                        Navigate;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetOwnRepair;
        if Worranty = true then
            WarantyTextEnabled := true
        else begin
            WarantyTextEnabled := false;
            "Warranty Text" := '';
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetOwnRepair;
        CustomerRepairSetup.Get;
        Validate("Customer Type", CustomerRepairSetup."Rep. Cust. Default");
    end;

    trigger OnOpenPage()
    begin
        Show := true;
        CurrPage.CustomerRepairJournal.PAGE.ShowField(Show);
    end;

    var
        CustomerRepairSetup: Record "NPR Customer Repair Setup";
        CustomerRepairGlobal: Record "NPR Customer Repair";
        ImageFound: Boolean;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Text10600001: Label 'Replace the existing picture ?';
        Text10600002: Label 'Delete picture ?';
        ErrNoReportFound: Label 'Report was not found.';
        [InDataSet]
        WarantyTextEnabled: Boolean;
        [InDataSet]
        RepairedNoEnabled: Boolean;
        [InDataSet]
        RepairNameEnabled: Boolean;
        [InDataSet]
        RepairAddressEnabled: Boolean;
        [InDataSet]
        RepairAddress2Enabled: Boolean;
        [InDataSet]
        RepairPostCodeEnabled: Boolean;
        [InDataSet]
        RepairCityEnabled: Boolean;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        TextName: Text[1024];
        Show: Boolean;
        Text10600004: Label 'Do you want to finalize the Repair?';
        Text10600005: Label 'Do you want to finalize and print the Repair?';
        EmailSent: Label ' E- mail Sent';
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";

    procedure SetOwnRepair()
    begin
        RepairedNoEnabled := not "In-house Repairer";
        RepairNameEnabled := not "In-house Repairer";
        RepairAddressEnabled := not "In-house Repairer";
        RepairAddress2Enabled := not "In-house Repairer";
        RepairPostCodeEnabled := not "In-house Repairer";
        RepairCityEnabled := not "In-house Repairer";

    end;

    local procedure SendMail(ReportNo: Integer; CustomerRep: Record "NPR Customer Repair")
    var
        Recref: RecordRef;
        EmailMgt: Codeunit "NPR E-mail Management";
    begin
        Recref.GetTable(CustomerRep);
        EmailMgt.SendReport(ReportNo, Recref, CustomerRep."E-mail", true);
    end;
}

