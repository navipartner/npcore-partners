report 6060132 "MM Membership Status"
{
    // NPR5.31/JLK /20170328  CASE 268638  Object created
    // MM1.24/JLK /20171129  CASE 296024  Added new fields on report
    // NPR5.42/TSA /20180122 CASE 301124 Removed caption from control container on request page
    // MM1.26/TSA /20180131 CASE 303848 changed to filter group 5 for the system filter on the member role record
    // NPR5.42/JLK /20180523 CASE 316228 Seperated first name and last name, added email newsletter
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
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
                begin
                    Clear(MemberDate);
                    Clear(MemberItem);
                    MMMembershipEntry.SetRange("Membership Entry No.","MM Membership"."Entry No.");
                    MMMembershipEntry.SetRange(Blocked,false);
                    if MMMembershipEntry.FindLast then begin
                      MemberDate := MMMembershipEntry."Valid Until Date";
                      if MMMembershipEntry."Item No." <> '' then
                        if Item.Get(MMMembershipEntry."Item No.") then
                            MemberItem := Item.Description;
                    end;

                    case MembershipStatus of
                      MembershipStatus::Active : begin
                        if AsOfToday then begin
                          if not (MemberDate >= Today) then
                            CurrReport.Skip;
                        end else begin
                         if not ((MemberDate >= StartDate) and (MemberDate <= EndDate)) then
                            CurrReport.Skip;
                        end;
                      end;
                      MembershipStatus::Expired : begin
                        if AsOfToday then begin
                          if (MemberDate > Today) then
                            CurrReport.Skip;
                        end else begin
                          if ((MemberDate >= StartDate) and (MemberDate <= EndDate)) then
                            CurrReport.Skip;
                        end;
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
            column(AsOfToday;AsOfToday)
            {
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

            trigger OnAfterGetRecord()
            begin
                Evaluate(ConvValidDate,Description);
                Evaluate(MMMembershipIssueDate,"Description 2");

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
                    field(MembershipStatus;MembershipStatus)
                    {
                        Caption = 'Membership Status';
                    }
                    field(AsOfToday;AsOfToday)
                    {
                        Caption = 'As of Today';
                    }
                    field(StartDate;StartDate)
                    {
                        Caption = 'Start Date';
                        Editable = NOT AsOfToday;
                    }
                    field(EndDate;EndDate)
                    {
                        Caption = 'End Date';
                        Editable = NOT AsOfToday;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin

            AsOfToday := true;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if Filters = '' then
          Filters += MembershipStatusCaption + ' ' + Format(MembershipStatus)
        else
          Filters += ' | ' + MembershipStatusCaption + ' ' + Format(MembershipStatus);

        if AsOfToday then begin
          if Filters = '' then
            Filters += DateFilterCaption + ' ' + Format(Today)
          else
            Filters += ' | ' + DateFilterCaption + ' ' + Format(Today);
        end else begin
          if Filters = '' then
            Filters += DateFilterCaption + ' ' + Format(StartDate) + '..' + Format(EndDate)
          else
            Filters += ' | ' + DateFilterCaption + ' ' + Format(StartDate) + '..' + Format(EndDate);
        end;
    end;

    var
        MemberName: Text;
        MemberDate: Date;
        CompanyInformation: Record "Company Information";
        MMMembershipEntry: Record "MM Membership Entry";
        MMMemberCard: Record "MM Member Card";
        MemberItem: Text;
        MembershipStatus: Option Active,Expired;
        StartDate: Date;
        EndDate: Date;
        [InDataSet]
        AsOfToday: Boolean;
        MMMember2: Record "MM Member";
        PageCaption: Label 'Page %1 of %2';
        ReportCaption: Label 'Membership Status';
        MemberEntryNoCaption: Label 'Entry No.';
        DateCaption: Label 'Valid Until Date';
        ConvValidDate: Date;
        Filters: Text;
        MembershipStatusCaption: Label 'Membership Status:';
        DateFilterCaption: Label 'Date:';
        FilterCaption: Label 'Filters';
        MMMembershipIssueDate: Date;
        ExternalMemberNoCaption: Label 'Ext. Member No.';
        ExternalMembershipNoCaption: Label 'Ext. Membership No.';
        MembershipIssuedDateCaption: Label 'Membership Issue Date';
}

