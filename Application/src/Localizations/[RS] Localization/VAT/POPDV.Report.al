report 6014454 "NPR POPDV"
{
    UsageCategory = None;
#IF NOT BC17
    Extensible = false;
#ENDIF
    WordLayout = './src/Localizations/[RS] Localization/VAT/POPDV.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(Integer; Integer)
        {
            MaxIteration = 1;
            column(CompanyDetails; CompanyDetails) { }
            column(VATRegistration; CompanyInformation."VAT Registration No.") { }
            column(StartDate; Format(StartDate)) { }
            column(EndDate; Format(EndDate)) { }
            column(Field1_1; TempVATEVEntry."Field 1_1") { }
            column(Field1_2; TempVATEVEntry."Field 1_2") { }
            column(Field1_3; TempVATEVEntry."Field 1_3") { }
            column(Field1_4; TempVATEVEntry."Field 1_4") { }
            column(Field1_5; TempVATEVEntry."Field 1_5") { }
            column(Field1_6; TempVATEVEntry."Field 1_6") { }
            column(Field1_7; TempVATEVEntry."Field 1_7") { }
            column(Field2_1; TempVATEVEntry."Field 2_1") { }
            column(Field2_2; TempVATEVEntry."Field 2_2") { }
            column(Field2_3; TempVATEVEntry."Field 2_3") { }
            column(Field2_4; TempVATEVEntry."Field 2_4") { }
            column(Field2_5; TempVATEVEntry."Field 2_5") { }
            column(Field2_6; TempVATEVEntry."Field 2_6") { }
            column(Field2_7; TempVATEVEntry."Field 2_7") { }
            column(Field3_1_1; TempVATEVEntry."Field 3_1_1") { }
            column(Field3_1_2; TempVATEVEntry."Field 3_1_2") { }
            column(Field3_1_3; TempVATEVEntry."Field 3_1_3") { }
            column(Field3_1_4; TempVATEVEntry."Field 3_1_4") { }
            column(Field3_2_1; TempVATEVEntry."Field 3_2_1") { }
            column(Field3_2_2; TempVATEVEntry."Field 3_2_2") { }
            column(Field3_2_3; TempVATEVEntry."Field 3_2_3") { }
            column(Field3_2_4; TempVATEVEntry."Field 3_2_4") { }
            column(Field3_3_1; TempVATEVEntry."Field 3_3_1") { }
            column(Field3_3_2; TempVATEVEntry."Field 3_3_2") { }
            column(Field3_3_3; TempVATEVEntry."Field 3_3_3") { }
            column(Field3_3_4; TempVATEVEntry."Field 3_3_4") { }
            column(Field3_4_1; TempVATEVEntry."Field 3_4_1") { }
            column(Field3_4_2; TempVATEVEntry."Field 3_4_2") { }
            column(Field3_4_3; TempVATEVEntry."Field 3_4_3") { }
            column(Field3_4_4; TempVATEVEntry."Field 3_4_4") { }
            column(Field3_5_1; TempVATEVEntry."Field 3_5_1") { }
            column(Field3_5_2; TempVATEVEntry."Field 3_5_2") { }
            column(Field3_5_3; TempVATEVEntry."Field 3_5_3") { }
            column(Field3_5_4; TempVATEVEntry."Field 3_5_4") { }
            column(Field3_6_1; TempVATEVEntry."Field 3_6_1") { }
            column(Field3_6_2; TempVATEVEntry."Field 3_6_2") { }
            column(Field3_6_3; TempVATEVEntry."Field 3_6_3") { }
            column(Field3_6_4; TempVATEVEntry."Field 3_6_4") { }
            column(Field3_7_1; TempVATEVEntry."Field 3_7_1") { }
            column(Field3_7_2; TempVATEVEntry."Field 3_7_2") { }
            column(Field3_7_3; TempVATEVEntry."Field 3_7_3") { }
            column(Field3_7_4; TempVATEVEntry."Field 3_7_4") { }
            column(Field3_8_1; TempVATEVEntry."Field 3_8_1") { }
            column(Field3_8_2; TempVATEVEntry."Field 3_8_2") { }
            column(Field3_8_3; TempVATEVEntry."Field 3_8_3") { }
            column(Field3_8_4; TempVATEVEntry."Field 3_8_4") { }
            column(Field3_9_1; TempVATEVEntry."Field 3_9_1") { }
            column(Field3_9_2; TempVATEVEntry."Field 3_9_2") { }
            column(Field3_9_3; TempVATEVEntry."Field 3_9_3") { }
            column(Field3_9_4; TempVATEVEntry."Field 3_9_4") { }
            column(Field3_10_2; TempVATEVEntry."Field 3_10_2") { }
            column(Field3_10_4; TempVATEVEntry."Field 3_10_4") { }
            column(Field3a_1_1; TempVATEVEntry."Field 3a_1_1") { }
            column(Field3a_1_2; TempVATEVEntry."Field 3a_1_2") { }
            column(Field3a_2_1; TempVATEVEntry."Field 3a_2_1") { }
            column(Field3a_2_2; TempVATEVEntry."Field 3a_2_2") { }
            column(Field3a_3_1; TempVATEVEntry."Field 3a_3_1") { }
            column(Field3a_3_2; TempVATEVEntry."Field 3a_3_2") { }
            column(Field3a_4_1; TempVATEVEntry."Field 3a_4_1") { }
            column(Field3a_4_2; TempVATEVEntry."Field 3a_4_2") { }
            column(Field3a_5_1; TempVATEVEntry."Field 3a_5_1") { }
            column(Field3a_5_2; TempVATEVEntry."Field 3a_5_2") { }
            column(Field3a_6_1; TempVATEVEntry."Field 3a_6_1") { }
            column(Field3a_6_2; TempVATEVEntry."Field 3a_6_2") { }
            column(Field3a_7_1; TempVATEVEntry."Field 3a_7_1") { }
            column(Field3a_7_2; TempVATEVEntry."Field 3a_7_2") { }
            column(Field3a_8_1; TempVATEVEntry."Field 3a_8_1") { }
            column(Field3a_8_2; TempVATEVEntry."Field 3a_8_2") { }
            column(Field3a_9_1; TempVATEVEntry."Field 3a_9_1") { }
            column(Field3a_9_2; TempVATEVEntry."Field 3a_9_2") { }
            column(Field4_1_1; TempVATEVEntry."Field 4_1_1") { }
            column(Field4_1_2; TempVATEVEntry."Field 4_1_2") { }
            column(Field4_1_3; TempVATEVEntry."Field 4_1_3") { }
            column(Field4_1_4; TempVATEVEntry."Field 4_1_4") { }
            column(Field4_2_1_1; TempVATEVEntry."Field 4_2_1_1") { }
            column(Field4_2_1_2; TempVATEVEntry."Field 4_2_1_2") { }
            column(Field4_2_2_1; TempVATEVEntry."Field 4_2_2_1") { }
            column(Field4_2_2_2; TempVATEVEntry."Field 4_2_2_2") { }
            column(Field4_2_3_1; TempVATEVEntry."Field 4_2_3_1") { }
            column(Field4_2_3_2; TempVATEVEntry."Field 4_2_3_2") { }
            column(Field4_2_4_3; TempVATEVEntry."Field 4_2_4_3") { }
            column(Field4_2_4_4; TempVATEVEntry."Field 4_2_4_4") { }
            column(Field5_1; TempVATEVEntry."Field 5_1") { }
            column(Field5_2; TempVATEVEntry."Field 5_2") { }
            column(Field5_3; TempVATEVEntry."Field 5_3") { }
            column(Field5_4; TempVATEVEntry."Field 5_4") { }
            column(Field5_5; TempVATEVEntry."Field 5_5") { }
            column(Field5_6; TempVATEVEntry."Field 5_6") { }
            column(Field5_7; TempVATEVEntry."Field 5_7") { }
            column(Field6_1; TempVATEVEntry."Field 6_1") { }
            column(Field6_2_1_1; TempVATEVEntry."Field 6_2_1_1") { }
            column(Field6_2_1_2; TempVATEVEntry."Field 6_2_1_2") { }
            column(Field6_2_2_1; TempVATEVEntry."Field 6_2_2_1") { }
            column(Field6_2_2_2; TempVATEVEntry."Field 6_2_2_2") { }
            column(Field6_2_3_1; TempVATEVEntry."Field 6_2_3_1") { }
            column(Field6_2_3_2; TempVATEVEntry."Field 6_2_3_2") { }
            column(Field6_3; TempVATEVEntry."Field 6_3") { }
            column(Field6_4; TempVATEVEntry."Field 6_4") { }
            column(Field7_1_1; TempVATEVEntry."Field 7_1_1") { }
            column(Field7_2_1; TempVATEVEntry."Field 7_2_1") { }
            column(Field7_3_2; TempVATEVEntry."Field 7_3_2") { }
            column(Field7_4_2; TempVATEVEntry."Field 7_4_2") { }
            column(Field8a_1_1; TempVATEVEntry."Field 8a_1_1") { }
            column(Field8a_1_2; TempVATEVEntry."Field 8a_1_2") { }
            column(Field8a_1_3; TempVATEVEntry."Field 8a_1_3") { }
            column(Field8a_1_4; TempVATEVEntry."Field 8a_1_4") { }
            column(Field8a_2_1; TempVATEVEntry."Field 8a_2_1") { }
            column(Field8a_2_2; TempVATEVEntry."Field 8a_2_2") { }
            column(Field8a_2_3; TempVATEVEntry."Field 8a_2_3") { }
            column(Field8a_2_4; TempVATEVEntry."Field 8a_2_4") { }
            column(Field8a_3_1; TempVATEVEntry."Field 8a_3_1") { }
            column(Field8a_3_2; TempVATEVEntry."Field 8a_3_2") { }
            column(Field8a_3_3; TempVATEVEntry."Field 8a_3_3") { }
            column(Field8a_3_4; TempVATEVEntry."Field 8a_3_4") { }
            column(Field8a_4_1; TempVATEVEntry."Field 8a_4_1") { }
            column(Field8a_4_2; TempVATEVEntry."Field 8a_4_2") { }
            column(Field8a_4_3; TempVATEVEntry."Field 8a_4_3") { }
            column(Field8a_4_4; TempVATEVEntry."Field 8a_4_4") { }
            column(Field8a_5_1; TempVATEVEntry."Field 8a_5_1") { }
            column(Field8a_5_2; TempVATEVEntry."Field 8a_5_2") { }
            column(Field8a_5_3; TempVATEVEntry."Field 8a_5_3") { }
            column(Field8a_5_4; TempVATEVEntry."Field 8a_5_4") { }
            column(Field8a_6_1; TempVATEVEntry."Field 8a_6_1") { }
            column(Field8a_6_3; TempVATEVEntry."Field 8a_6_3") { }
            column(Field8a_7_1; TempVATEVEntry."Field 8a_7_1") { }
            column(Field8a_7_2; TempVATEVEntry."Field 8a_7_2") { }
            column(Field8a_7_3; TempVATEVEntry."Field 8a_7_3") { }
            column(Field8a_7_4; TempVATEVEntry."Field 8a_7_4") { }
            column(Field8a_8_2; TempVATEVEntry."Field 8a_8_2") { }
            column(Field8a_8_4; TempVATEVEntry."Field 8a_8_4") { }
            column(Field8b_1_1; TempVATEVEntry."Field 8b_1_1") { }
            column(Field8b_1_2; TempVATEVEntry."Field 8b_1_2") { }
            column(Field8b_2_1; TempVATEVEntry."Field 8b_2_1") { }
            column(Field8b_2_2; TempVATEVEntry."Field 8b_2_2") { }
            column(Field8b_3_1; TempVATEVEntry."Field 8b_3_1") { }
            column(Field8b_3_2; TempVATEVEntry."Field 8b_3_2") { }
            column(Field8b_4_1; TempVATEVEntry."Field 8b_4_1") { }
            column(Field8b_4_2; TempVATEVEntry."Field 8b_4_2") { }
            column(Field8b_5_1; TempVATEVEntry."Field 8b_5_1") { }
            column(Field8b_5_2; TempVATEVEntry."Field 8b_5_2") { }
            column(Field8b_6_1; TempVATEVEntry."Field 8b_6_1") { }
            column(Field8b_6_2; TempVATEVEntry."Field 8b_6_2") { }
            column(Field8b_7_1; TempVATEVEntry."Field 8b_7_1") { }
            column(Field8b_7_2; TempVATEVEntry."Field 8b_7_2") { }
            column(Field8v_1; TempVATEVEntry."Field 8v_1") { }
            column(Field8v_2; TempVATEVEntry."Field 8v_2") { }
            column(Field8v_3; TempVATEVEntry."Field 8v_3") { }
            column(Field8v_4; TempVATEVEntry."Field 8v_4") { }
            column(Field8g_1_1; TempVATEVEntry."Field 8g_1_1") { }
            column(Field8g_1_2; TempVATEVEntry."Field 8g_1_2") { }
            column(Field8g_2_1; TempVATEVEntry."Field 8g_2_1") { }
            column(Field8g_2_2; TempVATEVEntry."Field 8g_2_2") { }
            column(Field8g_3_1; TempVATEVEntry."Field 8g_3_1") { }
            column(Field8g_3_2; TempVATEVEntry."Field 8g_3_2") { }
            column(Field8g_4_1; TempVATEVEntry."Field 8g_4_1") { }
            column(Field8g_4_2; TempVATEVEntry."Field 8g_4_2") { }
            column(Field8g_5_1; TempVATEVEntry."Field 8g_5_1") { }
            column(Field8g_5_2; TempVATEVEntry."Field 8g_5_2") { }
            column(Field8g_6_1; TempVATEVEntry."Field 8g_6_1") { }
            column(Field8g_6_2; TempVATEVEntry."Field 8g_6_2") { }
            column(Field8d_1; TempVATEVEntry."Field 8d_1") { }
            column(Field8d_2; TempVATEVEntry."Field 8d_2") { }
            column(Field8d_3; TempVATEVEntry."Field 8d_3") { }
            column(Field8dj; TempVATEVEntry."Field 8dj") { }
            column(Field8e_1; TempVATEVEntry."Field 8e_1") { }
            column(Field8e_2; TempVATEVEntry."Field 8e_2") { }
            column(Field8e_3; TempVATEVEntry."Field 8e_3") { }
            column(Field8e_4; TempVATEVEntry."Field 8e_4") { }
            column(Field8e_5; TempVATEVEntry."Field 8e_5") { }
            column(Field8e_6; TempVATEVEntry."Field 8e_6") { }
            column(Field9; TempVATEVEntry."Field 9") { }
            column(Field9a_1; TempVATEVEntry."Field 9a_1") { }
            column(Field9a_2; TempVATEVEntry."Field 9a_2") { }
            column(Field9a_3; TempVATEVEntry."Field 9a_3") { }
            column(Field9a_4; TempVATEVEntry."Field 9a_4") { }
            column(Field10; TempVATEVEntry."Field 10") { }
            column(Field11_1; TempVATEVEntry."Field 11_1") { }
            column(Field11_2; TempVATEVEntry."Field 11_2") { }
            column(Field11_3; TempVATEVEntry."Field 11_3") { }
        }
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        if StrLen(CompanyInformation.Address + CompanyInformation."Post Code" + CompanyInformation.City) > 0 then
            CompanyDetails := CompanyInformation.Name + ', ' + CompanyInformation.Address + ' ' + CompanyInformation."Post Code" + ' ' + CompanyInformation.City
        else
            CompanyDetails := CompanyInformation.Name;
    end;

    var
        CompanyInformation: Record "Company Information";
        TempVATEVEntry: Record "NPR VAT EV Entry" temporary;
        StartDate, EndDate : Date;
        CompanyDetails: Text;

    internal procedure SetDate(_StartDate: Date; _EndDate: Date)
    begin
        StartDate := _StartDate;
        EndDate := _EndDate;
    end;

    internal procedure SetRecord(_TempVATEVEntry: Record "NPR VAT EV Entry" temporary)
    begin
        TempVATEVEntry.Copy(_TempVATEVEntry, true);
    end;

}