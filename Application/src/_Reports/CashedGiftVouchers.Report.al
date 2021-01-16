report 6014403 "NPR Cashed Gift Vouchers"
{
    // NPR5.23/JLK/20160517  CASE 239487 Report created
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.38/JLK /20180125  CASE 303595 Added ENU object caption
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Cashed Gift Vouchers.rdlc';

    Caption = 'Cashed Gift Vouchers';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Gift Voucher"; "NPR Gift Voucher")
        {
            RequestFilterFields = "Issue Date", "Cashed Date";
            column(CreatedinCompany_GiftVoucher; ConvertCreatedCompanyNoToName("Gift Voucher"."Created in Company"))
            {
            }
            column(CashedinStore_GiftVoucher; ConvertCashedCompanyNoToName("Gift Voucher"."Cashed in Store"))
            {
            }
            column(No_GiftVoucher; "Gift Voucher"."No.")
            {
                IncludeCaption = true;
            }
            column(SalesTicketNo_GiftVoucher; "Gift Voucher"."Sales Ticket No.")
            {
                IncludeCaption = true;
            }
            column(IssueDate_GiftVoucher; "Gift Voucher"."Issue Date")
            {
                IncludeCaption = true;
            }
            column(Amount_GiftVoucher; "Gift Voucher".Amount)
            {
                IncludeCaption = true;
            }
            column(CashedDate_GiftVoucher; "Gift Voucher"."Cashed Date")
            {
                IncludeCaption = true;
            }
            column(ShowDetails; ShowDetails)
            {
            }
            column(ShowDetailsLbl; ShowDetailsLbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CreatedStringFilter; StrSubstNo(Text0003, CreatedStringFilter))
            {
            }
            column(CashedStringFilter; StrSubstNo(Text0002, CashedStringFilter))
            {
            }
            column(ReportNameLbl; ReportNameLbl)
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(GVFilters; StrSubstNo(GVFiltersLbl, GVFilters))
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(TotalForCompanyLbl; StrSubstNo(TotalForCompanyLbl, ConvertCreatedCompanyNoToName("Gift Voucher"."Created in Company")))
            {
            }

            trigger OnAfterGetRecord()
            begin

                if (StrPos(CreatedStringFilter, "Created in Company") = 0) or (StrPos(CashedStringFilter, "Cashed in Store") = 0) or ("Cashed in Store" = '') or ("Created in Company" = '') then
                    CurrReport.Skip;
            end;

            trigger OnPreDataItem()
            begin
                GVFilters := "Gift Voucher".GetFilters;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowDetails; ShowDetails)
                    {
                        Caption = 'ShowDetails';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ShowDetails field';
                    }
                }
                group("Created In Company")
                {
                    Caption = 'Created In Company';
                    grid(Control6150614)
                    {
                        GridLayout = Columns;
                        ShowCaption = false;
                        group(Control6150629)
                        {
                            ShowCaption = false;
                            field("CompanyList[1]"; CompanyList[1])
                            {
                                ShowCaption = false;
                                Visible = CompanyVisible1;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[1] field';
                            }
                            field("CompanyList[2]"; CompanyList[2])
                            {
                                ShowCaption = false;
                                Visible = CompanyVisible2;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[2] field';
                            }
                            field("CompanyList[3]"; CompanyList[3])
                            {
                                Visible = CompanyVisible3;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[3] field';
                            }
                            field("CompanyList[4]"; CompanyList[4])
                            {
                                Visible = CompanyVisible4;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[4] field';
                            }
                            field("CompanyList[5]"; CompanyList[5])
                            {
                                Visible = CompanyVisible5;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[5] field';
                            }
                            field("CompanyList[6]"; CompanyList[6])
                            {
                                Visible = CompanyVisible6;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[6] field';
                            }
                            field("CompanyList[7]"; CompanyList[7])
                            {
                                Visible = CompanyVisible7;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[7] field';
                            }
                            field("CompanyList[8]"; CompanyList[8])
                            {
                                Visible = CompanyVisible8;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList[8] field';
                            }
                        }
                        group(Control6150625)
                        {
                            ShowCaption = false;
                            field("CompanyListName[1]"; CompanyListName[1])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible1;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[1] field';
                            }
                            field("CompanyListName[2]"; CompanyListName[2])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible2;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[2] field';
                            }
                            field("CompanyListName[3]"; CompanyListName[3])
                            {
                                Editable = false;
                                Visible = CompanyVisible3;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[3] field';
                            }
                            field("CompanyListName[4]"; CompanyListName[4])
                            {
                                Editable = false;
                                Visible = CompanyVisible4;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[4] field';
                            }
                            field("CompanyListName[5]"; CompanyListName[5])
                            {
                                Editable = false;
                                Visible = CompanyVisible5;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[5] field';
                            }
                            field("CompanyListName[6]"; CompanyListName[6])
                            {
                                Editable = false;
                                Visible = CompanyVisible6;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[6] field';
                            }
                            field("CompanyListName[7]"; CompanyListName[7])
                            {
                                Editable = false;
                                Visible = CompanyVisible7;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[7] field';
                            }
                            field("CompanyListName[8]"; CompanyListName[8])
                            {
                                Editable = false;
                                Visible = CompanyVisible8;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[8] field';
                            }
                        }
                    }
                }
                group("Cashed In Company")
                {
                    Caption = 'Cashed In Company';
                    grid(Control6150655)
                    {
                        GridLayout = Columns;
                        ShowCaption = false;
                        group(Control6150654)
                        {
                            ShowCaption = false;
                            field("CompanyList2[1]"; CompanyList2[1])
                            {
                                ShowCaption = false;
                                Visible = CompanyVisible1;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[1] field';
                            }
                            field("CompanyList2[2]"; CompanyList2[2])
                            {
                                ShowCaption = false;
                                Visible = CompanyVisible2;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[2] field';
                            }
                            field("CompanyList2[3]"; CompanyList2[3])
                            {
                                Visible = CompanyVisible3;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[3] field';
                            }
                            field("CompanyList2[4]"; CompanyList2[4])
                            {
                                Visible = CompanyVisible4;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[4] field';
                            }
                            field("CompanyList2[5]"; CompanyList2[5])
                            {
                                Visible = CompanyVisible5;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[5] field';
                            }
                            field("CompanyList2[6]"; CompanyList2[6])
                            {
                                Visible = CompanyVisible6;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[6] field';
                            }
                            field("CompanyList2[7]"; CompanyList2[7])
                            {
                                Visible = CompanyVisible7;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[7] field';
                            }
                            field("CompanyList2[8]"; CompanyList2[8])
                            {
                                Visible = CompanyVisible8;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyList2[8] field';
                            }
                        }
                        group(Control6150645)
                        {
                            ShowCaption = false;
                            field(Control6150644; CompanyListName[1])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible1;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[1] field';
                            }
                            field(Control6150643; CompanyListName[2])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible2;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[2] field';
                            }
                            field(Control6150642; CompanyListName[3])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible3;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[3] field';
                            }
                            field(Control6150641; CompanyListName[4])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible4;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[4] field';
                            }
                            field(Control6150640; CompanyListName[5])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible5;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[5] field';
                            }
                            field(Control6150621; CompanyListName[6])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible6;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[6] field';
                            }
                            field(Control6150620; CompanyListName[7])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible7;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[7] field';
                            }
                            field(Control6150619; CompanyListName[8])
                            {
                                Editable = false;
                                ShowCaption = false;
                                Visible = CompanyVisible8;
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyListName[8] field';
                            }
                        }
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        Company: Record Company;
        Counter: Integer;
        RetailSetup: Record "NPR Retail Setup";
    begin
        Counter := 1;
        if Company.FindSet then
            repeat
                RetailSetup.ChangeCompany(Company.Name);
                if (RetailSetup.Get) and (RetailSetup."Company No." <> '') then begin
                    TMPBuffer.Init;
                    TMPBuffer.Template := Format(Counter);
                    TMPBuffer."Line No." := Counter;
                    TMPBuffer.Description := Company.Name;
                    TMPBuffer."Short Code 1" := RetailSetup."Company No.";
                    if TMPBuffer.Insert then begin
                        CompanyListName[Counter] := Company.Name;
                        case Counter of
                            1:
                                CompanyVisible1 := true;
                            2:
                                CompanyVisible2 := true;
                            3:
                                CompanyVisible3 := true;
                            4:
                                CompanyVisible4 := true;
                            5:
                                CompanyVisible5 := true;
                            6:
                                CompanyVisible6 := true;
                            7:
                                CompanyVisible7 := true;
                            8:
                                CompanyVisible8 := true;
                        end;
                        Counter := Counter + 1;
                    end;
                end;
            until Company.Next = 0;

        ShowDetails := true;

        for i := 1 to 8 do begin
            CompanyList[i] := true;
            CompanyList2[i] := true;
        end;
    end;

    trigger OnPreReport()
    begin
        CreatedStringFilter := '';
        CashedStringFilter := '';
        CompanyName2 := '';

        for i := 1 to 8 do begin
            if CompanyList[i] then begin
                CompanyName2 := CompanyListName[i];
                TMPBuffer.Reset;
                TMPBuffer.SetRange(Description, CompanyName2);
                if TMPBuffer.FindFirst then begin
                    if CreatedStringFilter <> '' then
                        CreatedStringFilter += '|' + TMPBuffer."Short Code 1"
                    else
                        CreatedStringFilter += TMPBuffer."Short Code 1";
                end;
            end;
        end;

        for i := 1 to 8 do begin
            if CompanyList2[i] then begin
                CompanyName2 := CompanyListName[i];
                TMPBuffer.Reset;
                TMPBuffer.SetRange(Description, CompanyName2);
                if TMPBuffer.FindFirst then begin
                    if CashedStringFilter <> '' then
                        CashedStringFilter += '|' + TMPBuffer."Short Code 1"
                    else
                        CashedStringFilter += TMPBuffer."Short Code 1";
                end;
            end;
        end;
    end;

    var
        TMPBuffer: Record "NPR TEMP Buffer" temporary;
        CompanyList: array[8] of Boolean;
        CompanyListName: array[8] of Text[30];
        CompanyList2: array[8] of Boolean;
        i: Integer;
        CreatedStringFilter: Text[30];
        CashedStringFilter: Text[30];
        Text0001: Label 'Created in %1 (%2)';
        Text0002: Label 'Cashed in %1';
        ShowDetails: Boolean;
        Text0003: Label 'Created in %1';
        ReportNameLbl: Label 'Cashed Gift Voucher';
        ShowDetailsLbl: Label 'Show Details: ';
        PageLbl: Label 'Page';
        GVFilters: Text[100];
        GVFiltersLbl: Label 'Filters: %1';
        TotalLbl: Label 'Total';
        TotalForCompanyLbl: Label 'Total for %1';
        [InDataSet]
        CompanyVisible1: Boolean;
        [InDataSet]
        CompanyVisible2: Boolean;
        [InDataSet]
        CompanyVisible3: Boolean;
        [InDataSet]
        CompanyVisible4: Boolean;
        [InDataSet]
        CompanyVisible5: Boolean;
        [InDataSet]
        CompanyVisible6: Boolean;
        [InDataSet]
        CompanyVisible7: Boolean;
        [InDataSet]
        CompanyVisible8: Boolean;
        CompanyName2: Text[30];

    local procedure ConvertCreatedCompanyNoToName(CompanyNo: Text): Text
    begin
        TMPBuffer.Reset;
        if TMPBuffer.FindSet then
            repeat
                if CompanyNo = TMPBuffer."Short Code 1" then
                    exit(StrSubstNo(Text0001, TMPBuffer.Description, TMPBuffer."Short Code 1"));
            until TMPBuffer.Next = 0;

        exit('');
    end;

    local procedure ConvertCashedCompanyNoToName(CompanyNo: Text): Text
    begin
        TMPBuffer.Reset;
        if TMPBuffer.FindSet then
            repeat
                if CompanyNo = TMPBuffer."Short Code 1" then
                    exit(StrSubstNo(Text0002, TMPBuffer.Description));
            until TMPBuffer.Next = 0;

        exit('');
    end;
}

