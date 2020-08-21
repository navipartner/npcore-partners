page 6014503 "Customer Repair Card"
{
    // NPR70.00.00.02/BHR/20150130 CASE 204899 Pass variable to show additional fields on lines.
    //                                         create Action Finalize
    // NPR5.25/TS  /20160615  CASE 244140 Removed ReportValg Variable to ReportSelectionPhoto and moved from global to local. Replaced Register No. on SETRANGE as Register field is beinf filled instead
    // NPR5.26/TS  /20160809  CASE 248351 Fix Insert Picture. Removed  CustomerType1 and Added Customer Type
    // NPR5.27/TS  /20161009  CASE 254679 Corrected In house Repairer
    // NPR5.27/TS  /20161017  CASE 254715 Added Field Item Description
    // NPR5.27/TS  /20161018  CASE 254659 Added Report Sending by Mail
    // NPR5.27/MHA /20161025  CASE 255580 Update Action: Send Status Sms
    // NPR5.29/TS  /20161212  CASE 260764 Updated Tab Name Invoive to Invoice To
    // NPR5.30/BHR /20170203  CASE 262923 Add field "Bag No.", Add action PrintLabel,Add FactBox Notes
    // NPR5.35/TJ  /20170823  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.36/KENU/20170710  CASE 278925 Changed REPORT.RUN to use function RunReport from Codeunit "Report Printer Interface"
    // NPR5.40/TS  /20180105  CASE 300893 Group Invoice to renamed to Invoiced To
    // NPR5.40/TS  /20180308  CASE 307591 Removed Find Repair Card
    // NPR5.40/TS  /20180315  CASE 307592 Split General Tab
    // NPR5.52/ANPA/20190920  CASE 369594 Removed page actions input and delete from section pictures from actiongroup <Action6150715>
    // NPR5.52/ANPA/20190920  CASE 369595 Removed Fax No. field

    Caption = 'Customer Repair Card';
    PromotedActionCategories = 'New,Process,Reports,Pictures,Tasks';
    SourceTable = "Customer Repair";

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
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        // LS 13-05-10
                        // Added to get customer ledger entries for the customer
                        if "Customer No." <> '' then begin
                            CustLedgerEntry.Reset;
                            CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", "Customer No.");
                            PAGE.RunModal(PAGE::"Customer Ledger Entries", CustLedgerEntry)
                        end;
                        // END of LS 13-05-10
                    end;
                }
                field(Name; Name)
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
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Contact Person"; "Contact Person")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field("Bag No"; "Bag No")
                {
                    ApplicationArea = All;
                }
                field("Contact after"; "Contact after")
                {
                    ApplicationArea = All;
                }
                field("Delivery reff."; "Delivery reff.")
                {
                    ApplicationArea = All;
                }
                field(Finalized; Finalized)
                {
                    ApplicationArea = All;
                }
            }
            group("Repairer Details")
            {
                Caption = 'Repairer Details';
                field("In-house Repairer"; "In-house Repairer")
                {
                    ApplicationArea = All;

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
                }
                field("Repairer Name"; "Repairer Name")
                {
                    ApplicationArea = All;
                    Enabled = RepairNameEnabled;
                }
                field("Repairer Address"; "Repairer Address")
                {
                    ApplicationArea = All;
                    Enabled = RepairAddressEnabled;
                }
                field("Repairer Address2"; "Repairer Address2")
                {
                    ApplicationArea = All;
                    Enabled = RepairAddress2Enabled;
                }
                field("Repairer Post Code"; "Repairer Post Code")
                {
                    ApplicationArea = All;
                    Enabled = RepairPostCodeEnabled;
                }
                field("Repairer City"; "Repairer City")
                {
                    ApplicationArea = All;
                    Enabled = RepairCityEnabled;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
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

                        trigger OnValidate()
                        begin
                            //-NPR5.27
                            // LS 18/05/10 - CASE 88117
                            //IF "Item No."<> '' THEN
                            //  IF ItemRec.GET("Item No.") THEN
                            //   ItemDesc:=ItemRec.Description;

                            // END of LS 18/05/10 - CASE 88117
                            //+NPR5.27
                        end;
                    }
                    field("Item Description"; "Item Description")
                    {
                        ApplicationArea = All;
                    }
                    field("Unit Cost"; "Unit Cost")
                    {
                        ApplicationArea = All;
                    }
                    field("Variant Code"; "Variant Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Variant code';
                    }
                    field(Worranty; Worranty)
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            //-NPR5.27
                            WarantyTextEnabled := Worranty;
                            //+NPR5.27
                        end;
                    }
                    field("Warranty Text"; "Warranty Text")
                    {
                        ApplicationArea = All;
                        Enabled = WarantyTextEnabled;
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                    }
                    field(Brand; Brand)
                    {
                        ApplicationArea = All;
                    }
                    field("Serial No."; "Serial No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Alt. Serial No."; "Alt. Serial No.")
                    {
                        ApplicationArea = All;
                    }
                    field(Accessories; Accessories)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Accessories 1"; "Accessories 1")
                    {
                        ApplicationArea = All;
                    }
                    field("Costs Paid by Offer"; "Costs Paid by Offer")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150658)
                {
                    ShowCaption = false;
                    field("Prices Including VAT"; "Prices Including VAT")
                    {
                        ApplicationArea = All;
                    }
                    field("To Ship"; "To Ship")
                    {
                        ApplicationArea = All;
                    }
                    field("Handed In Date"; "Handed In Date")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Expected Completion Date"; "Expected Completion Date")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Date Delivered"; "Date Delivered")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Delivering Salespers."; "Delivering Salespers.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Delivering Sales Ticket No."; "Delivering Sales Ticket No.")
                    {
                        ApplicationArea = All;
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
                    }
                    field("Customer Name"; "Customer Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Address"; "Customer Address")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Address 2"; "Customer Address 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Post Code"; "Customer Post Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer City"; "Customer City")
                    {
                        ApplicationArea = All;
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
                    }
                    field(Delivered; Delivered)
                    {
                        ApplicationArea = All;
                    }
                    field("Service nr."; "Service nr.")
                    {
                        ApplicationArea = All;
                    }
                    field(Type; Type)
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Answer"; "Customer Answer")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150685)
                {
                    ShowCaption = false;
                    field("Requested Returned, No Repair"; "Requested Returned, No Repair")
                    {
                        ApplicationArea = All;
                    }
                    field("Approved by repairer"; "Approved by repairer")
                    {
                        ApplicationArea = All;
                    }
                    field("Return from Repair"; "Return from Repair")
                    {
                        ApplicationArea = All;
                    }
                    field(Claimed; Claimed)
                    {
                        ApplicationArea = All;
                    }
                    field("Offer Sent"; "Offer Sent")
                    {
                        ApplicationArea = All;
                    }
                    field("Reported Ready and Sent"; "Reported Ready and Sent")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Defect Description")
            {
                Caption = 'Defect Description';
                part(vv; "Customer Repair Journal")
                {
                    SubPageLink = "Customer Repair No." = FIELD("No."),
                                  Type = CONST(Fejlbeskrivelse);
                }
            }
            group("Repair Description")
            {
                Caption = 'Repair Description';
                part(CustomerRepairJournal; "Customer Repair Journal")
                {
                    SubPageLink = "Customer Repair No." = FIELD("No."),
                                  Type = CONST(Reparationsbeskrivelse);
                }
            }
            group(Picture)
            {
                Caption = 'Picture';
                field("Picture Documentation1"; "Picture Documentation1")
                {
                    ApplicationArea = All;
                }
                field("Picture Documentation2"; "Picture Documentation2")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014416; Notes)
            {
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                        MatrixPrintMgt: Codeunit "RP Matrix Print Mgt.";
                        RecRef: RecordRef;
                        RecID: RecordID;
                    begin
                        //-NPR5.30 [262923]
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair Label");
                        if ReportSelectionContract.FindFirst then begin
                            RecRef.Open(DATABASE::"Customer Repair");
                            RecID := Rec.RecordId;
                            RecRef.Get(RecID);
                            RecRef.SetRecFilter;
                            if ReportSelectionContract."Codeunit ID" = CODEUNIT::"RP Matrix Print Mgt." then
                                MatrixPrintMgt.ProcessTemplate(ReportSelectionContract."Print Template", RecRef);
                        end;
                        //+NPR5.30 [262923]
                    end;
                }
                action("&Repair Offer")
                {
                    Caption = '&Repair Offer';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        //-NPR5.25
                        //REPORT.RUN(REPORT::"Repair Offer",TRUE,FALSE,rep);
                        //+NPR5.25

                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair offer");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        //-NPR5.25
                        //ReportSelectionPhoto.SETRANGE("Register No.","Register No.");
                        ReportSelectionContract.SetRange("Register No.", Register);
                        //+NPR5.25
                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');

                        //-NPR5.25
                        //IF ReportSelectionPhoto.FIND('-') THEN BEGIN
                        if ReportSelectionContract.FindSet then begin
                            //+NPR5.25
                            repeat
                                //-NPR5.36
                                //REPORT.RUNMODAL(ReportSelectionPhoto."Report ID",TRUE,FALSE,rep);
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, false, CustomerRepairGlobal);
                            //+NPR5.36
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        //-NPR5.25
                        //REPORT.RUN(REPORT::"Repair Done",TRUE,FALSE,rep);
                        //+NPR5.25
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair finished");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        //-NPR5.25
                        //ReportSelectionPhoto.SETRANGE("Register No.","Register No.");
                        ReportSelectionContract.SetRange("Register No.", Register);
                        //+NPR5.25

                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');
                        //-NPR5.25
                        //IF ReportSelectionPhoto.FIND('-') THEN BEGIN
                        if ReportSelectionContract.FindSet then begin
                            //+NPR5.25
                            repeat
                                //-NPR5.36
                                //REPORT.RUNMODAL(ReportSelectionPhoto."Report ID",TRUE,FALSE,rep);
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, false, CustomerRepairGlobal);
                            //+NPR5.36
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        //-NPR5.25
                        //REPORT.RUN(REPORT::"Repair Warranty",TRUE,FALSE,rep);
                        //+NPR5.25
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Repair warranty");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        //-NPR5.25
                        //ReportSelectionPhoto.SETRANGE("Register No.","Register No.");
                        ReportSelectionContract.SetRange("Register No.", Register);
                        //+NPR5.25

                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');
                        //-NPR5.25
                        //IF ReportSelectionPhoto.FIND('-') THEN BEGIN
                        if ReportSelectionContract.FindSet then begin
                            //+NPR5.25
                            repeat
                                //-NPR5.36
                                //REPORT.RUNMODAL(ReportSelectionPhoto."Report ID",TRUE,FALSE,rep);
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", true, false, CustomerRepairGlobal);
                            //+NPR5.36
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        //-NPR5.25
                        //REPORT.RUN(REPORT::"Repair Receipt",TRUE,FALSE,rep);
                        //+NPR5.25
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Customer receipt");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        //-NPR5.25
                        //ReportSelectionPhoto.SETRANGE("Register No.","Register No.");
                        ReportSelectionContract.SetRange("Register No.", Register);
                        //+NPR5.25
                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');
                        //-NPR5.25
                        //IF ReportSelectionPhoto.FIND('-') THEN BEGIN
                        if ReportSelectionContract.FindSet then begin
                            //+NPR5.25
                            repeat
                                //-NPR5.36
                                //REPORT.RUNMODAL(ReportSelectionPhoto."Report ID",TRUE,FALSE,rep);
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", false, false, CustomerRepairGlobal);
                            //+NPR5.36
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        CustomerRepairGlobal := Rec;
                        CustomerRepairGlobal.SetRecFilter;
                        //-NPR5.25
                        //REPORT.RUN(REPORT::"Delivery Note for Repair",TRUE,FALSE,rep);
                        //+NPR5.25
                        ReportSelectionContract.SetRange("Report Type", ReportSelectionContract."Report Type"::"Shipment note");
                        ReportSelectionContract.SetFilter("Report ID", '<> 0');
                        //ReportSelectionPhoto.SETRANGE("Register No.","Register No.");
                        ReportSelectionContract.SetRange("Register No.", Register);
                        //+NPR5.25
                        if not ReportSelectionContract.Find('-') then
                            ReportSelectionContract.SetRange("Register No.", '');
                        //-NPR5.25
                        //IF ReportSelectionPhoto.FIND('-') THEN BEGIN
                        if ReportSelectionContract.FindSet then begin
                            //+NPR5.25
                            repeat
                                //-NPR5.36
                                //REPORT.RUNMODAL(ReportSelectionPhoto."Report ID",TRUE,FALSE,rep);
                                ReportPrinterInterface.RunReport(ReportSelectionContract."Report ID", false, false, CustomerRepairGlobal);
                            //+NPR5.36
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
                        PromotedCategory = Category4;

                        trigger OnAction()
                        var
                            RecRef: RecordRef;
                        begin
                            //-NPR5.25
                            //TextName:="Picture Documentation1".IMPORT(Text10600000,TRUE);
                            //+NPR5.25
                            ImageFound := "Picture Documentation1".HasValue;
                            Clear(TempBlob);
                            //-NPR5.26
                            //Name := FileManagement.BLOBImport(TempBlob,TextName);
                            "Picture Path 1" := FileManagement.BLOBImport(TempBlob, TextName);
                            //+NPR5.26
                            RecRef.GetTable(Rec);
                            TempBlob.ToRecordRef(RecRef, FieldNo("Picture Documentation1"));
                            RecRef.SetTable(Rec);
                            //-NPR5.26
                            //IF Name= '' THEN
                            //  EXIT;
                            if "Picture Path 1" = '' then
                                exit;
                            //+NPR5.26
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
                        PromotedCategory = Category4;

                        trigger OnAction()
                        var
                            CustomerRepair: Record "Customer Repair";
                        begin
                            Clear(TempBlob);
                            //-NPR5.26
                            //CALCFIELDS("Picture Documentation1");

                            //TempBlob.Blob := "Picture Documentation1";
                            //IF "Picture Documentation1".HASVALUE THEN
                            //   Name := FileManagement.BLOBExport(TempBlob,TextName,TRUE);
                            CustomerRepair.SetRange("No.", "No.");
                            if CustomerRepair.FindFirst then begin
                                CustomerRepair.CalcFields("Picture Documentation1");
                                TempBlob.FromRecord(CustomerRepair, CustomerRepair.FieldNo("Picture Documentation1"));
                                if CustomerRepair."Picture Documentation1".HasValue then
                                    FileManagement.BLOBExport(TempBlob, CustomerRepair."Picture Path 1", true);
                            end;
                            //+NPR5.26
                        end;
                    }
                    action("&Delete")
                    {
                        Caption = '&Delete';
                        Image = Delete;
                        Promoted = true;
                        PromotedCategory = Category4;

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
                        PromotedCategory = Category4;

                        trigger OnAction()
                        var
                            CustomerRepair: Record "Customer Repair";
                        begin
                            Clear(TempBlob);
                            //-NPR5.26
                            //CALCFIELDS("Picture Documentation1");

                            //TempBlob.Blob := "Picture Documentation2";
                            //IF "Picture Documentation2".HASVALUE THEN
                            //   Name := FileManagement.BLOBExport(TempBlob,TextName,TRUE);
                            CustomerRepair.SetRange("No.", "No.");
                            if CustomerRepair.FindFirst then begin
                                CustomerRepair.CalcFields("Picture Documentation2");
                                TempBlob.FromRecord(CustomerRepair, CustomerRepair.FieldNo("Picture Documentation2"));
                                if CustomerRepair."Picture Documentation2".HasValue then
                                    FileManagement.BLOBExport(TempBlob, CustomerRepair."Picture Path 2", true);
                            end;
                            //+NPR5.26
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
                    RunObject = Page "Customer Repair List";
                    RunPageView = WHERE(Status = FILTER(<> Claimed));
                    ShortCutKey = 'F5';
                }
                action("Repair Closed/Claimed List")
                {
                    Caption = 'Repair Closed/Claimed List';
                    Image = List;
                    RunObject = Page "Customer Repair List";
                    RunPageView = WHERE(Status = FILTER(Claimed));
                    ShortCutKey = 'F5';
                }
                action("Finalize Repair")
                {
                    Caption = 'Finalize Repair';
                    Image = Close;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        //-NPR70.00.00.02
                        if Confirm(Text10600004, true) then
                            PostItemPart(Rec);
                        //+NPR70.00.00.02
                    end;
                }
                action("Post Items")
                {
                    Caption = 'Post Items';
                    Image = Post;
                    Promoted = true;

                    trigger OnAction()
                    begin
                        //-NPR5.26
                        PostItemPartWithoutFinalize(Rec);
                        //+NPR5.26
                    end;
                }
                action("Finalize Repair and Print")
                {
                    Caption = 'Finalize Repair and Print';
                    Image = Close;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        //-NPR70.00.00.02
                        if Confirm(Text10600005, true) then begin
                            PostItemPart(Rec);
                            SetRecFilter;
                            if xRec.Finalized = false then
                                REPORT.RunModal(6014502, false, true, Rec);
                        end;
                        //+NPR70.00.00.02
                    end;
                }
                action("Send Status Sms")
                {
                    Caption = 'Send Status Sms';
                    Image = SendElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    var
                        RetailContractMgt: Codeunit "Retail Contract Mgt.";
                    begin
                        //-NPR5.27
                        //SendStatusSMS;
                        RetailContractMgt.SendStatusSms(Rec);
                        //+NPR5.27
                    end;
                }
                action("Send Custom Sms")
                {
                    Caption = 'Send Custom Sms';
                    Image = SendTo;
                    RunObject = Page "Send SMS";
                }
                action("Create Invoice")
                {
                    Caption = 'Create Invoice';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        CreateSalesDocument(2);
                    end;
                }
                action("Create Sales Order")
                {
                    Caption = 'Create Sales Order';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        CreateSalesDocument(1);
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

                    trigger OnAction()
                    var
                        CustomerRepair: Record "Customer Repair";
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        //-NPR5.27
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
                        //+NPR5.27
                    end;
                }
                action("Email Repair Done")
                {
                    Caption = 'Email Repair Done';
                    Image = Email;

                    trigger OnAction()
                    var
                        CustomerRepair: Record "Customer Repair";
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        //-NPR5.27
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
                        //+NPR5.27
                    end;
                }
                action("Email Repair Guarantee")
                {
                    Caption = 'Email Repair Guarantee';
                    Image = Email;

                    trigger OnAction()
                    var
                        CustomerRepair: Record "Customer Repair";
                        ReportSelectionContract: Record "Report Selection - Contract";
                    begin
                        //-NPR5.27
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
                        //+NPR5.27
                    end;
                }
                action("Email Customer Note")
                {
                    Caption = 'Email Customer Note';
                    Image = Email;

                    trigger OnAction()
                    var
                        CustomerRepair: Record "Customer Repair";
                        ReportSelectionContract: Record "Report Selection - Contract";
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
        //-NPR5.40
        //IF xRec."No." <> "No." THEN
        //  SearchNoEnabled := TRUE;
        //+NPR5.40
        if Worranty = true then
            WarantyTextEnabled := true
        else begin
            WarantyTextEnabled := false;
            "Warranty Text" := '';
        end;

        //-NPR5.27
        // LS 18/05/10 - CASE 88117

        //IF "Item No."<> '' THEN BEGIN
        //  ItemRec.RESET;
        //  IF ItemRec.GET("Item No.") THEN
        //    ItemDesc := ItemRec.Description;
        //END;
        // END of LS 18/05/10 - CASE 88117
        //+NPR5.27
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.27
        SetOwnRepair;
        //+NPR5.27
        RetailSetup.Get;
        Validate("Customer Type", RetailSetup."Rep. Cust. Default");
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.40
        //SearchNoEnabled := TRUE;
        //+NPR5.40
        //-NPR70.00.00.02
        Show := true;
        CurrPage.CustomerRepairJournal.PAGE.ShowField(Show);
        //+NPR70.00.00.02
    end;

    var
        RetailSetup: Record "Retail Setup";
        CustomerRepairGlobal: Record "Customer Repair";
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
        ReportPrinterInterface: Codeunit "Report Printer Interface";

    procedure SetOwnRepair()
    begin
        //-NPR5.25
        /*
        CurrForm."Repairer No.".ENABLED( NOT "In-house Repairer" );
        CurrForm."Repairer Name".ENABLED( NOT "In-house Repairer" );
        CurrForm."Repairer Address".ENABLED( NOT "In-house Repairer" );
        CurrForm."Repairer Address2".ENABLED( NOT "In-house Repairer" );
        CurrForm."Repairer Post Code".ENABLED( NOT "In-house Repairer" );
        CurrForm."Repairer City".ENABLED( NOT "In-house Repairer" );
         */
        //+NPR5.25
        RepairedNoEnabled := not "In-house Repairer";
        RepairNameEnabled := not "In-house Repairer";
        RepairAddressEnabled := not "In-house Repairer";
        RepairAddress2Enabled := not "In-house Repairer";
        RepairPostCodeEnabled := not "In-house Repairer";
        RepairCityEnabled := not "In-house Repairer";

    end;

    local procedure SendMail(ReportNo: Integer; CustomerRep: Record "Customer Repair")
    var
        Recref: RecordRef;
        EmailMgt: Codeunit "E-mail Management";
    begin
        //-NPR5.27
        Recref.GetTable(CustomerRep);
        EmailMgt.SendReport(ReportNo, Recref, CustomerRep."E-mail", true);
        //+NPR5.27
    end;
}

