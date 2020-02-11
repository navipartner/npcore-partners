report 6060132 "MM Membership Status"
{
    // NPR5.31/JLK /20170328  CASE 268638  Object created
    // MM1.24/JLK /20171129  CASE 296024  Added new fields on report
    // NPR5.42/TSA /20180122 CASE 301124 Removed caption from control container on request page
    // MM1.26/TSA /20180131 CASE 303848 changed to filter group 5 for the system filter on the member role record
    // NPR5.42/JLK /20180523 CASE 316228 Seperated first name and last name, added email newsletter
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
    // MM1.41/TSA /20191011 CASE 355444 Refactored
    // MM1.42/TSA /20191213 CASE 382181 Refactored again, adding options for "active and renewed", "active and not renewed", + general clean-up
    DefaultLayout = RDLC;
    RDLCLayout = './MM Membership Status.rdlc';

    Caption = 'Membership Status';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("MM Membership Setup";"MM Membership Setup")
        {
            dataitem("MM Membership";"MM Membership")
            {
                DataItemLink = "Membership Code"=FIELD(Code);
                dataitem("MM Membership Role";"MM Membership Role")
                {
                    //The property 'DataItemTableView' shouldn't have an empty value.
                    //DataItemTableView = '';
                    dataitem("MM Member";"MM Member")
                    {
                        DataItemLink = "Entry No."=FIELD("Member Entry No.");

                        trigger OnAfterGetRecord()
                        var
                            BarcodeLib: Codeunit "Barcode Library";
                        begin
                            TempMembers.Init;
                            TempMembers.Template := "MM Membership Setup".Code;
                            TempMembers."Line No." := "MM Member"."Entry No.";
                            TempMembers.Description := Format(MemberDate);
                            TempMembers.Color := "MM Membership"."Entry No.";
                            //-MM1.24
                            TempMembers."Code 1" := "MM Membership"."External Membership No.";
                            TempMembers."Description 2" := Format("MM Membership"."Issued Date");
                            //+MM1.24

                            //-MM1.41 [355444]
                            TempMembers."Code 3" := Format (ValidUntilDate);
                            TempMembers."Code 4" := Format (ValidFromDate);
                            //+MM1.41 [355444]

                            TempMembers.Insert;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        //-MM1.26 [303848]
                        //"MM Membership Role".SETFILTER ("Member Role", '=%1|=%2', "MM Membership Role"."Member Role"::ADMIN, "MM Membership Role"."Member Role"::MEMBER);

                        "MM Membership Role".FilterGroup (2);
                        "MM Membership Role".SetFilter ("Membership Entry No." ,'=%1', "MM Membership"."Entry No.");
                        "MM Membership Role".SetFilter ("Member Role", '=%1|=%2', "MM Membership Role"."Member Role"::ADMIN, "MM Membership Role"."Member Role"::MEMBER);
                        "MM Membership Role".FilterGroup (0);
                        //+MM1.26 [303848]
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                    MembershipManagement: Codeunit "MM Membership Management";
                    ValidForReferenceDate: Boolean;
                    KeepMembership: Boolean;
                    NewRefDate: Date;
                begin

                    ValidForReferenceDate := MembershipManagement.GetMembershipValidDate ("MM Membership"."Entry No.", ReferenceDate, ValidFromDate, ValidUntilDate);

                    case MembershipStatus of
                      MembershipStatus::Active :
                        begin

                          if (not ValidForReferenceDate) then
                            CurrReport.Skip;

                          if (Format (ExpiresWithinDateformula) <> '') then
                            if (CalcDate (ExpiresWithinDateformula, ReferenceDate) < ValidUntilDate) then
                              CurrReport.Skip;

                        end;

                      MembershipStatus::"Active and Renewed",
                      MembershipStatus::"Active and Not Renewed" :
                        begin

                          if (not ValidForReferenceDate) then
                            CurrReport.Skip;

                          if (Format (ExpiresWithinDateformula) <> '') then
                            if (CalcDate (ExpiresWithinDateformula, ReferenceDate) < ValidUntilDate) then
                              CurrReport.Skip;

                          NewRefDate := CalcDate ('<+1D>', ValidUntilDate); // default renew is back-to-back
                          if (Format (RenewedWithin) <> '') then
                            NewRefDate := CalcDate (RenewedWithin, ValidUntilDate);

                          ValidForReferenceDate := MembershipManagement.GetMembershipValidDate ("MM Membership"."Entry No.", NewRefDate, ValidFromDate, ValidUntilDate);

                          if (ValidForReferenceDate) and (MembershipStatus = MembershipStatus::"Active and Not Renewed") then
                            CurrReport.Skip;

                          if (not ValidForReferenceDate) and (MembershipStatus = MembershipStatus::"Active and Renewed") then
                            CurrReport.Skip;

                        end;

                      MembershipStatus::"Not Active" :
                        if (ValidForReferenceDate) then
                          CurrReport.Skip;
                    end;
                end;
            }
        }
        dataitem(TempMembers;"NPR - TEMP Buffer")
        {
            DataItemTableView = SORTING(Template,"Line No.");
            UseTemporary = true;
            column(Code_Membership;Template)
            {
            }
            column(EntryNo_Member;"Line No.")
            {
            }
            column(ValidToDate;ConvValidDate)
            {
            }
            column(FirstName_Member;MMMember2."First Name")
            {
                IncludeCaption = true;
            }
            column(LastName_Member;MMMember2."Last Name")
            {
                IncludeCaption = true;
            }
            column(Address_Member;MMMember2.Address)
            {
                IncludeCaption = true;
            }
            column(PostCode_Member;MMMember2."Post Code Code")
            {
            }
            column(City_Member;MMMember2.City)
            {
            }
            column(CountryCode_Member;MMMember2."Country Code")
            {
            }
            column(Email_Member;MMMember2."E-Mail Address")
            {
                IncludeCaption = true;
            }
            column(EmailNewsLetter_Member;MMMember2."E-Mail News Letter")
            {
                IncludeCaption = true;
            }
            column(PageCaption;PageCaption)
            {
            }
            column(ReportCaption;ReportCaption)
            {
            }
            column(MemberEntryNoCaption;MemberEntryNoCaption)
            {
            }
            column(DateCaption;DateCaption)
            {
            }
            column(Filters;Filters)
            {
            }
            column(FilterCaption;FilterCaption)
            {
            }
            column(ExternalMembershipNo_Membership;TempMembers."Code 1")
            {
            }
            column(ExternalMemberNo_Member;MMMember2."External Member No.")
            {
            }
            column(IssuedDate_Membership;MMMembershipIssueDate)
            {
            }
            column(ExternalMemberNoCaption;ExternalMemberNoCaption)
            {
            }
            column(ExternalMembershipNoCaption;ExternalMembershipNoCaption)
            {
            }
            column(IssuedDateCaption;MembershipIssuedDateCaption)
            {
            }
            column(ValidFromDate;ValidFromDate)
            {
            }
            column(ValidUntilDate;ValidUntilDate)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Evaluate(ConvValidDate,Description);
                Evaluate(MMMembershipIssueDate,"Description 2");

                //-MM1.41 [355444]
                Evaluate (ValidUntilDate, TempMembers."Code 3");
                Evaluate (ValidFromDate, TempMembers."Code 4");
                //+MM1.41 [355444]

                // CLEAR(MemberName);
                // IF MMMember2.GET("Line No.") THEN BEGIN
                //  IF MMMember2."First Name" <> '' THEN
                //    MemberName += MMMember2."First Name" + ' ';
                //  IF MMMember2."Middle Name" <> '' THEN
                //    MemberName += MMMember2."Middle Name" + ' ';
                //  IF MMMember2."Last Name" <> '' THEN
                //    MemberName += MMMember2."Last Name";
                // END;

                if MMMember2.Get("Line No.") then;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(ReferenceDate;ReferenceDate)
                    {
                        Caption = 'Reference Date';
                    }
                    field(MembershipStatus;MembershipStatus)
                    {
                        Caption = 'Membership Status On Reference Date';
                    }
                    field(ExpiresWithinDateformula;ExpiresWithinDateformula)
                    {
                        Caption = 'Expires Within (Active)';
                        Editable = (MembershipStatus < 3);
                    }
                    field(RenewedWithin;RenewedWithin)
                    {
                        Caption = 'Renewed Within (Active)';
                        Editable = (MembershipStatus < 3);
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin

            //-MM1.41 [355444]
            // AsOfToday := TRUE;
            //+MM1.41 [355444]
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin

        ReferenceDate := Today;
    end;

    trigger OnPreReport()
    begin

        if Filters = '' then
          Filters += MembershipStatusCaption + ' ' + Format(MembershipStatus)
        else
          Filters += ' | ' + MembershipStatusCaption + ' ' + Format(MembershipStatus);

        Filters += ' | ' + DateFilterCaption + ' ' + Format(ReferenceDate);
        Filters += ' | ' + ExpireWithinCaption + ' ' + Format(ExpiresWithinDateformula);
        Filters += StrSubstNo (' | %1: %2', RenewedWithinCaption, Format(RenewedWithin));
    end;

    var
        MemberName: Text;
        MemberDate: Date;
        CompanyInformation: Record "Company Information";
        MMMembershipEntry: Record "MM Membership Entry";
        MMMemberCard: Record "MM Member Card";
        MemberItem: Text;
        MembershipStatus: Option Active,"Active and Renewed","Active and Not Renewed","Not Active";
        MMMember2: Record "MM Member";
        PageCaption: Label 'Page %1 of %2';
        ReportCaption: Label 'Membership Status';
        MemberEntryNoCaption: Label 'Entry No.';
        DateCaption: Label 'Membership Valid Date';
        ConvValidDate: Date;
        Filters: Text;
        MembershipStatusCaption: Label 'Membership Status:';
        DateFilterCaption: Label 'Date:';
        FilterCaption: Label 'Filters';
        MMMembershipIssueDate: Date;
        ExternalMemberNoCaption: Label 'Ext. Member No.';
        ExternalMembershipNoCaption: Label 'Ext. Membership No.';
        MembershipIssuedDateCaption: Label 'Membership Issue Date';
        ReferenceDate: Date;
        ExpiresWithinDateformula: DateFormula;
        ValidFromDate: Date;
        ValidUntilDate: Date;
        ExpireWithinCaption: Label 'Expires Within:';
        ShowActiveMemberships: Boolean;
        RenewedWithin: DateFormula;
        RenewedWithinCaption: Label 'Renewed Within:';

    local procedure CheckForSkip()
    begin
    end;
}

