report 6014573 "NPR RS Retail Trial Balance"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/Localizations/[RS] Retail Localization/Retail Price Calculation/Reports/RS Retail Trial Balance.rdlc';
    Caption = 'RS Retail Trial Balance';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRSRLocal;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(Company_Name; "Name") { }
            column(Company_AddressCityPostCode; StrSubStNo(_AddressFormatLbl, Address, "Post Code", City)) { }
            column(PeriodFilterText; StrSubStNo(_PeriodFormatLbl, _StartDateFilter, _EndDateFilter)) { }
            column(DateFilterText; StrSubStNo(_DateFilterFormatLbl, _StartDateFilter, _EndDateFilter)) { }
            column(StartBalanceDateFilter; Format(CalcDate('<-1D>', _StartDateFilter))) { }
            column(StartEndDateText; StrSubStNo(_StartEndDateFormatLbl, _StartDateFilter, _EndDateFilter)) { }
            column(StartDateFilter; _StartDateFilter) { }
            column(EndDateFilter; _EndDateFilter) { }

            trigger OnPreDataItem()
            begin
                SetLoadFields("Name", Address, "Post Code", City);
            end;
        }
        dataitem(GL_Account; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Account Type";

            column(GL_Account_No; "No.") { }
            column(GL_Account_Name; "Name") { }
            column(GL_Account_NetChange; "Net Change") { }
            column(GL_Account_Indentation; Indentation) { }
            column(GL_Account_NoOfBLankLines; "No. of Blank Lines") { }
            column(GL_Account_StartBalanceDebit; _StartBalanceDebit) { }
            column(GL_Account_StartBalanceCredit; _StartBalanceCredit) { }
            column(GL_Account_NetChangeDebit; "Debit Amount") { }
            column(GL_Account_NetChangeCredit; "Credit Amount") { }
            column(GL_Account_NetChangeBalanceDebit; _NetChangeBalanceDebit) { }
            column(GL_Account_NetChangeBalanceCredit; _NetChangeBalanceCredit) { }
            column(GL_Account_EndBalanceDebit; _EndBalanceDebit) { }
            column(GL_Account_EndBalanceCredit; _EndBalanceCredit) { }
            column(GL_Account_FilterText; _GLAccountFilterText) { }

            trigger OnPreDataItem()
            begin
                GL_Account.SetRange("Date Filter", _StartDateFilter, _EndDateFilter);
                SetLoadFields("No.", "Name", Indentation, "No. of Blank Lines");
                SetAutoCalcFields("Debit Amount", "Credit Amount", "Balance at Date", "Net Change");
            end;

            trigger OnAfterGetRecord()
            begin
                CalculateStartingBalance();
                CalculateNetChangeBalance();
                if (_SkipNoNetChangeAccounts) and ((_NetChangeBalanceDebit = 0) and (_NetChangeBalanceCredit = 0)) then
                    CurrReport.Skip();
                CalculateEndingBalance();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(SkipNoNetChangeAccounts; _SkipNoNetChangeAccounts)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Skip No Net Change Accounts';
                        ToolTip = 'If selected, accounts with no net change during the period will be excluded from the report.';
                    }
                    field(StartDateFilter; _StartDateFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the starting date of the period for which the trial balance is calculated.';
                        ShowMandatory = true;
                    }
                    field(EndDateFilter; _EndDateFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the ending date of the period for which the trial balance is calculated.';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    labels
    {
        ReportTitleLbl = 'RS Retail Trial Balance';
        GlAccountNoLbl = 'No.';
        GlAccountNameLbl = 'Name';
        GlAccountStartBalanceLbl = 'Starting Balance';
        GlAccountNetChangeLbl = 'Net Change';
        GlAccountNetChangeBalanceLbl = 'Net Change Balance';
        GlAccountEndBalanceLbl = 'Ending Balance';
        DebitLbl = 'Debit';
        CreditLbl = 'Credit';
    }

    trigger OnPreReport()
    begin
        if (_StartDateFilter = 0D) or (_EndDateFilter = 0D) then
            Error(_StartEndDateMustBeSpecifiedErr);
        if _StartDateFilter > _EndDateFilter then
            Error(_StartDateMustBeBeforeEndDateErr);

        if GL_Account.GetFilters() <> '' then
            _GLAccountFilterText := GL_Account.TableCaption() + ' ' + GL_Account.GetFilters();
    end;

    local procedure CalculateStartingBalance()
    var
        GLAccount: Record "G/L Account";
    begin
        Clear(_StartBalanceDebit);
        Clear(_StartBalanceCredit);
        if not GLAccount.Get(GL_Account."No.") then
            exit;
        GLAccount.CopyFilters(GL_Account);
        GLAccount.SetFilter("Date Filter", '..%1', CalcDate('<-1D>', _StartDateFilter));
        GLAccount.CalcFields("Balance at Date");
        if GLAccount."Balance at Date" >= 0 then
            _StartBalanceDebit := GLAccount."Balance at Date"
        else
            _StartBalanceCredit := -GLAccount."Balance at Date";
    end;

    local procedure CalculateNetChangeBalance()
    begin
        _NetChangeBalanceDebit := GL_Account."Debit Amount" + _StartBalanceDebit;
        _NetChangeBalanceCredit := GL_Account."Credit Amount" + _StartBalanceCredit;
    end;

    local procedure CalculateEndingBalance()
    begin
        Clear(_EndBalanceDebit);
        Clear(_EndBalanceCredit);
        if GL_Account."Balance at Date" >= 0 then
            _EndBalanceDebit := GL_Account."Balance at Date"
        else
            _EndBalanceCredit := -GL_Account."Balance at Date";
    end;

    var
        _AddressFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 - Address, %2 - Post Code, %3 - City';
        _PeriodFormatLbl: Label 'Period: %1 - %2', Locked = true, Comment = '%1 - Start Date, %2 - End Date';
        _DateFilterFormatLbl: Label 'Date: %1..%2', Locked = true, Comment = '%1 - Start Date, %2 - End Date';
        _StartEndDateFormatLbl: Label '%1..%2', Locked = true, Comment = '%1 - Start Date, %2 - End Date';
        _StartEndDateMustBeSpecifiedErr: Label 'Start Date and End Date must be specified.';
        _StartDateMustBeBeforeEndDateErr: Label 'Start Date must be before End Date.';
        _GLAccountFilterText: Text;
        _StartDateFilter: Date;
        _EndDateFilter: Date;
        _StartBalanceDebit: Decimal;
        _StartBalanceCredit: Decimal;
        _NetChangeBalanceDebit: Decimal;
        _NetChangeBalanceCredit: Decimal;
        _EndBalanceDebit: Decimal;
        _EndBalanceCredit: Decimal;
        _SkipNoNetChangeAccounts: Boolean;
}
