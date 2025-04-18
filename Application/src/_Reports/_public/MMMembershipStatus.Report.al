﻿report 6060132 "NPR MM Membership Status"
{
#if not BC17 
#if BC18 or BC19
    Extensible = false;
#else
    Extensible = true;
#endif
#endif
    Caption = 'Membership Status';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    DataAccessIntent = ReadOnly;
#if BC17 or BC18 or BC19
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Membership Status.rdlc';
#else
    DefaultRenderingLayout = "RDLC Layout";
#endif

    dataset
    {
        dataitem("MM Membership Setup"; "NPR MM Membership Setup")
        {
            RequestFilterFields = "Code", "Loyalty Code";
            dataitem("MM Membership"; "NPR MM Membership")
            {
                DataItemLink = "Membership Code" = FIELD(Code);
                RequestFilterFields = "Company Name", "Community Code", "Membership Code", "Customer No.";
                dataitem("MM Membership Role"; "NPR MM Membership Role")
                {
                    RequestFilterFields = "Member Role";
                    dataitem("MM Member"; "NPR MM Member")
                    {
                        DataItemLink = "Entry No." = FIELD("Member Entry No.");
                        RequestFilterFields = "First Name", "Middle Name", "Last Name", "Country Code";

                        trigger OnAfterGetRecord()
                        begin
                            TempMembers.Init();
                            TempMembers.Template := "MM Membership Setup".Code;
                            TempMembers."Line No." := "MM Member"."Entry No.";
                            TempMembers.Description := Format(MemberDate);
                            TempMembers.Color := "MM Membership"."Entry No.";
                            TempMembers."Code 1" := "MM Membership"."External Membership No.";
                            TempMembers."Description 2" := Format("MM Membership"."Issued Date");
                            TempMembers."Code 3" := Format(ValidUntilDate);
                            TempMembers."Code 4" := Format(ValidFromDate);
                            TempMembers.Insert();
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        "MM Membership Role".FilterGroup(2);
                        "MM Membership Role".SetFilter("Membership Entry No.", '=%1', "MM Membership"."Entry No.");
                        "MM Membership Role".SetFilter("Member Role", '=%1|=%2', "MM Membership Role"."Member Role"::ADMIN, "MM Membership Role"."Member Role"::MEMBER);
                        "MM Membership Role".FilterGroup(0);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
                    ValidForReferenceDate: Boolean;
                    NewRefDate: Date;
                begin

                    ValidForReferenceDate := MembershipManagement.GetMembershipValidDate("MM Membership"."Entry No.", ReferenceDate, ValidFromDate, ValidUntilDate);

                    case MembershipStatus of
                        MembershipStatus::Active:
                            begin
                                if (not ValidForReferenceDate) then
                                    CurrReport.Skip();

                                if (Format(ExpiresWithinDateformula) <> '') then
                                    if (CalcDate(ExpiresWithinDateformula, ReferenceDate) < ValidUntilDate) then
                                        CurrReport.Skip();
                            end;

                        MembershipStatus::"Active and Renewed",
                        MembershipStatus::"Active and Not Renewed":
                            begin

                                if (not ValidForReferenceDate) then
                                    CurrReport.Skip();

                                if (Format(ExpiresWithinDateformula) <> '') then
                                    if (CalcDate(ExpiresWithinDateformula, ReferenceDate) < ValidUntilDate) then
                                        CurrReport.Skip();

                                NewRefDate := CalcDate('<+1D>', ValidUntilDate); // default renew is back-to-back
                                if (Format(RenewedWithin) <> '') then
                                    NewRefDate := CalcDate(RenewedWithin, ValidUntilDate);

                                ValidForReferenceDate := MembershipManagement.GetMembershipValidDate("MM Membership"."Entry No.", NewRefDate, ValidFromDate, ValidUntilDate);

                                if (ValidForReferenceDate) and (MembershipStatus = MembershipStatus::"Active and Not Renewed") then
                                    CurrReport.Skip();

                                if (not ValidForReferenceDate) and (MembershipStatus = MembershipStatus::"Active and Renewed") then
                                    CurrReport.Skip();
                            end;

                        MembershipStatus::"Not Active":
                            if (ValidForReferenceDate) then
                                CurrReport.Skip();
                    end;
                end;
            }
        }
        dataitem(TempMembers; "NPR TEMP Buffer")
        {
            DataItemTableView = SORTING(Template, "Line No.");
            UseTemporary = true;
            column(Code_Membership; Template)
            {
            }
            column(EntryNo_Member; "Line No.")
            {
            }
            column(ValidToDate; ConvValidDate)
            {
            }
            column(FirstName_Member; MMMember2."First Name")
            {
                IncludeCaption = true;
            }
            column(LastName_Member; MMMember2."Last Name")
            {
                IncludeCaption = true;
            }
            column(Address_Member; MMMember2.Address)
            {
                IncludeCaption = true;
            }
            column(PostCode_Member; MMMember2."Post Code Code")
            {
            }
            column(City_Member; MMMember2.City)
            {
            }
            column(CountryCode_Member; MMMember2."Country Code")
            {
            }
            column(Email_Member; MMMember2."E-Mail Address")
            {
                IncludeCaption = true;
            }
            column(EmailNewsLetter_Member; MMMember2."E-Mail News Letter")
            {
                IncludeCaption = true;
            }
            column(PageCaption; PageCaption)
            {
            }
            column(ReportCaption; ReportCaption)
            {
            }
            column(MemberEntryNoCaption; MemberEntryNoCaption)
            {
            }
            column(DateCaption; DateCaption)
            {
            }
            column(Filters; Filters)
            {
            }
            column(FilterCaption; FilterCaption)
            {
            }
            column(ExternalMembershipNo_Membership; TempMembers."Code 1")
            {
            }
            column(ExternalMemberNo_Member; MMMember2."External Member No.")
            {
            }
            column(IssuedDate_Membership; MMMembershipIssueDate)
            {
            }
            column(ExternalMemberNoCaption; ExternalMemberNoCaption)
            {
            }
            column(ExternalMembershipNoCaption; ExternalMembershipNoCaption)
            {
            }
            column(IssuedDateCaption; MembershipIssuedDateCaption)
            {
            }
            column(ValidFromDate; ValidFromDate)
            {
            }
            column(ValidUntilDate; ValidUntilDate)
            {
            }
            column(Date2Caption; Date2Caption)
            {
            }
            column(City_Caption; City_Caption)
            {
            }
            column(ZipCode_Caption; ZipCode_Caption)
            {
            }
            column(Country_Caption; Country_Caption)
            {
            }
            column(MembershipType_Caption; MembershipType_Caption)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Evaluate(ConvValidDate, Description);
                Evaluate(MMMembershipIssueDate, "Description 2");
                Evaluate(ValidUntilDate, TempMembers."Code 3");
                Evaluate(ValidFromDate, TempMembers."Code 4");
                if (MMMember2.Get("Line No.")) then;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("Reference Date"; ReferenceDate)
                    {

                        Caption = 'Reference Date';
                        ToolTip = 'Specifies the value of the Reference Date field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Membership Status"; MembershipStatus)
                    {

                        Caption = 'Membership Status On Reference Date';
                        OptionCaption = 'Active,Active and Renewed,Active and Not Renewed,Not Active';
                        ToolTip = 'Specifies the value of the Membership Status On Reference Date field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Expires Within Date formula"; ExpiresWithinDateformula)
                    {

                        Caption = 'Expires Within (Active)';
                        Editable = (MembershipStatus < 3);
                        ToolTip = 'Specifies the value of the Expires Within (Active) field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Renewed Within"; RenewedWithin)
                    {

                        Caption = 'Renewed Within (Active)';
                        Editable = (MembershipStatus < 3);
                        ToolTip = 'Specifies the value of the Renewed Within (Active) field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
            }
        }
    }

#if not (BC17 or BC18 or BC19)
    rendering
    {
        layout("RDLC Layout")
        {
            Caption = 'RDLC layout';
            LayoutFile = './src/_Reports/layouts/MM Membership Status.rdlc';
            Type = RDLC;
        }
        layout("Excel Layout")
        {
            Caption = 'Excel layout';
            LayoutFile = './src/_Reports/layouts/MM Membership Status.xlsx';
            Type = Excel;
        }
    }

#endif

    trigger OnInitReport()
    begin

        ReferenceDate := Today();
    end;

    trigger OnPreReport()
    begin

        if (Filters = '') then
            Filters += MembershipStatusCaption + ' ' + Format(MembershipStatus)
        else
            Filters += ' | ' + MembershipStatusCaption + ' ' + Format(MembershipStatus);

        Filters += ' | ' + DateFilterCaption + ' ' + Format(ReferenceDate);
        Filters += ' | ' + ExpireWithinCaption + ' ' + Format(ExpiresWithinDateformula);
        Filters += StrSubstNo(Pct1Lbl, RenewedWithinCaption, Format(RenewedWithin));
    end;

    var
        MMMember2: Record "NPR MM Member";
        ExpiresWithinDateformula: DateFormula;
        RenewedWithin: DateFormula;
        ConvValidDate: Date;
        MemberDate: Date;
        MMMembershipIssueDate: Date;
        ReferenceDate: Date;
        ValidFromDate: Date;
        ValidUntilDate: Date;
        City_Caption: Label 'City';
        Country_Caption: Label 'Country';
        DateFilterCaption: Label 'Date:';
        MemberEntryNoCaption: Label 'Entry No.';
        ExpireWithinCaption: Label 'Expires Within:';
        ExternalMemberNoCaption: Label 'Ext. Member No.';
        ExternalMembershipNoCaption: Label 'Ext. Membership No.';
        FilterCaption: Label 'Filters';
        DateCaption: Label 'From Date';
        MembershipIssuedDateCaption: Label 'Membership Issue Date';
        ReportCaption: Label 'Membership Status';
        MembershipStatusCaption: Label 'Membership Status:';
        PageCaption: Label 'Page %1 of %2';
        ZipCode_Caption: Label 'Postcode';
        RenewedWithinCaption: Label 'Renewed Within:';
        MembershipType_Caption: Label 'Type';
        Date2Caption: Label 'Until Date';
        MembershipStatus: Option Active,"Active and Renewed","Active and Not Renewed","Not Active";
        Filters: Text;
        Pct1Lbl: Label ' | %1: %2', locked = true;
}

