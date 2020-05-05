report 6060136 "MM Membership Not Renewed"
{
    // MM1.42/TSA /20191212 CASE 382181 Initial Version
    DefaultLayout = RDLC;
    RDLCLayout = './MM Membership Not Renewed.rdlc';

    Caption = 'Membership Not Renewed';
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
                    MembershipEntry: Record "MM Membership Entry";
                    MembershipManagement: Codeunit "MM Membership Management";
                    ValidForReferenceDate: Boolean;
                    ValidForReferenceDate2: Boolean;
                    KeepMembership: Boolean;
                    NextRefDate: Date;
                begin

                    ValidForReferenceDate := MembershipManagement.GetMembershipValidDate ("MM Membership"."Entry No.", ReferenceDate, ValidFromDate, ValidUntilDate);

                    if (ValidForReferenceDate) then begin
                      MembershipEntry.SetFilter ("Membership Entry No.", '=%1', "MM Membership"."Entry No.");
                      MembershipEntry.SetFilter ("Valid From Date", '=%1', ValidFromDate);
                      MembershipEntry.SetFilter ("Valid Until Date", '=%1', ValidUntilDate);
                      ValidForReferenceDate := MembershipEntry.FindFirst ();
                    end;

                    case MembershipStatus of
                      MembershipStatus::Active       : if (not ValidForReferenceDate) then CurrReport.Skip ();
                      MembershipStatus::"Not Active" : if (ValidForReferenceDate) then CurrReport.Skip ();
                      MembershipStatus::New          : if (not ValidForReferenceDate) or (MembershipEntry.Context <> MembershipEntry.Context::NEW) then CurrReport.Skip ();
                      MembershipStatus::Renew        : if (not ValidForReferenceDate) or (MembershipEntry.Context <> MembershipEntry.Context::RENEW) then CurrReport.Skip ();
                      MembershipStatus::Extend       : if (not ValidForReferenceDate) or (MembershipEntry.Context <> MembershipEntry.Context::EXTEND) then CurrReport.Skip ();
                      MembershipStatus::Upgrade      : if (not ValidForReferenceDate) or (MembershipEntry.Context <> MembershipEntry.Context::UPGRADE) then CurrReport.Skip ();
                    end;

                    if (ReferenceDate2 > ReferenceDate) then begin
                      ValidForReferenceDate2 := MembershipManagement.GetMembershipValidDate ("MM Membership"."Entry No.", ReferenceDate2, ValidFromDate, ValidUntilDate);

                      if (ValidForReferenceDate2) then begin
                        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', "MM Membership"."Entry No.");
                        MembershipEntry.SetFilter ("Valid From Date", '=%1', ValidFromDate);
                        MembershipEntry.SetFilter ("Valid Until Date", '=%1', ValidUntilDate);
                        ValidForReferenceDate2 := MembershipEntry.FindFirst ();
                      end;

                      case MembershipStatus2 of
                        MembershipStatus2::Active       : if (not ValidForReferenceDate2) then CurrReport.Skip ();
                        MembershipStatus2::"Not Active" : if (ValidForReferenceDate2) then CurrReport.Skip ();
                        MembershipStatus2::New          : if (not ValidForReferenceDate2) or (MembershipEntry.Context <> MembershipEntry.Context::NEW) then CurrReport.Skip ();
                        MembershipStatus2::Renew        : if (not ValidForReferenceDate2) or (MembershipEntry.Context <> MembershipEntry.Context::RENEW) then CurrReport.Skip ();
                        MembershipStatus2::Extend       : if (not ValidForReferenceDate2) or (MembershipEntry.Context <> MembershipEntry.Context::EXTEND) then CurrReport.Skip ();
                        MembershipStatus2::Upgrade      : if (not ValidForReferenceDate2) or (MembershipEntry.Context <> MembershipEntry.Context::UPGRADE) then CurrReport.Skip ();
                      end;

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
                        Caption = 'Reference Date 1';
                    }
                    field(MembershipStatus;MembershipStatus)
                    {
                        Caption = 'Membership Status (Reference Date 1)';
                    }
                    field(ReferenceDate2;ReferenceDate2)
                    {
                        Caption = 'Reference Date 2';
                    }
                    field(MembershipStatus2;MembershipStatus2)
                    {
                        Caption = 'Membership Status (Reference Date 2)';
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
        ReferenceDate2 := 0D;
    end;

    trigger OnPreReport()
    begin

        if Filters = '' then
          Filters += MembershipStatusCaption + ' ' + Format(MembershipStatus)
        else
          Filters += ' | ' + MembershipStatusCaption + ' ' + Format(MembershipStatus);
    end;

    var
        MemberName: Text;
        MemberDate: Date;
        CompanyInformation: Record "Company Information";
        MMMembershipEntry: Record "MM Membership Entry";
        MMMemberCard: Record "MM Member Card";
        MemberItem: Text;
        MembershipStatus: Option Active,"Not Active",New,Renew,Upgrade,Extend;
        MembershipStatus2: Option " ",Active,"Not Active",New,Renew,Upgrade,Extend;
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
        ReferenceDate2: Date;
        ValidFromDate: Date;
        ValidUntilDate: Date;
        ShowActiveMemberships: Boolean;

    local procedure CheckForSkip()
    begin
    end;
}

