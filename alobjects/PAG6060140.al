page 6060140 "MM POS Member Card"
{
    // MM1.10/TSA/20160405  CASE 234209 Transport MM1.10 - 22 March 2016
    // MM1.11/TSA/20160418  CASE 239328 Added some more fields and chroma coding of good and abad values
    // MM1.18/NAV/20170309  CASE 263198 Transport MM1.18 - 8 March 2017
    // MM1.19/TSA/20170518  CASE 276779 Better handling of ValidUntilDate when membership is expired.
    // MM1.19/TSA/20170519  case 276779 added the GetMembershipMaxValidUntilDate() function
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.23/NPKNAV/20171025  CASE 257011 Transport MM1.23 - 25 October 2017
    // MM1.26/TSA /20180124 CASE 299690 Added button Add Guardian and Activate Membership, clean-up
    // MM1.27/TSA /20180321 CASE 308756 Added output for RemainingPoints
    // MM1.29/TSA /20180511 CASE 314687 Added Contact Profile Questionnair
    // MM1.29/TSA /20180511 CASE 313795 Added GDPR option for guardian
    // MM1.34/TSA /20180907 CASE 327605 Open / Due Amount field
    // MM1.40/TSA /20190823 CASE 360242 Cleaned Green Code
    // MM1.41/TSA /20191008 CASE 366261 When Clienttype is Phone, there is no "LookupOK"

    Caption = 'Member Details';
    DataCaptionExpression = "External Member No." + ' - ' + "Display Name";
    DeleteAllowed = false;
    InsertAllowed = false;
    ShowFilter = false;
    SourceTable = "MM Member";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Picture;Picture)
                {
                }
                field("External Member No.";"External Member No.")
                {
                    Editable = false;
                }
                field("Display Name";"Display Name")
                {
                }
                field(Gender;Gender)
                {
                }
                field(Birthday;Birthday)
                {
                    Style = Favorable;
                    StyleExpr = IsBirthday;
                }
                field(Blocked;Blocked)
                {
                    Style = Unfavorable;
                    StyleExpr = IsInvalid;
                }
                field("Blocked At";"Blocked At")
                {
                    Style = Unfavorable;
                    StyleExpr = IsInvalid;
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("E-Mail Address";"E-Mail Address")
                {
                }
                field("E-Mail News Letter";"E-Mail News Letter")
                {
                }
                field("MembershipRoleDisplay.""GDPR Approval""";MembershipRoleDisplay."GDPR Approval")
                {
                    Caption = 'GDPR Approval';
                    Editable = false;
                }
            }
            group(Membership)
            {
                Caption = 'Membership';
                Editable = false;
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Columns;
                field("Membership.""External Membership No.""";Membership."External Membership No.")
                {
                    Caption = 'External Membership No.';
                }
                field("Membership.""Membership Code""";Membership."Membership Code")
                {
                    Caption = 'Membership Code';
                }
                field("Membership.""Company Name""";Membership."Company Name")
                {
                    Caption = 'Company Name';
                }
                group(Control6014407)
                {
                    ShowCaption = false;
                    field(RemainingPoints;RemainingPoints)
                    {
                        Caption = 'Remaining Points';
                        Editable = false;
                    }
                    field(ValidFromDate;ValidFromDate)
                    {
                        Caption = 'Valid From Date';
                        Visible = false;
                    }
                    field(ValidUntilDate;ValidUntilDate)
                    {
                        Caption = 'Valid Until Date';
                        Style = Unfavorable;
                        StyleExpr = UntilDateAttentionAccent;
                    }
                    field(RemainingAmountText;RemainingAmountText)
                    {
                        Caption = 'Open / Due Amount.';
                        Style = Unfavorable;
                        StyleExpr = AccentuateDueAmount;
                    }
                }
            }
            part(MemberCardsSubpage;"MM Member Cards ListPart")
            {
                SubPageLink = "Member Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("Entry No.")
                              ORDER(Descending);
            }
        }
        area(factboxes)
        {
            systempart(Control6014400;Notes)
            {
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Member Card")
            {
                Caption = 'Member Card';
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Member Card";
                RunPageLink = "Entry No."=FIELD("Entry No.");
            }
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MemberWebService: Codeunit "MM Member WebService";
                    ResponseMessage: Text;
                begin

                    //-MM1.41 [366261]
                    if (not MemberWebService.MemberRegisterArrival ("External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                      Error (ResponseMessage);

                    Message (ResponseMessage);
                    //+MM1.41 [366261]
                end;
            }
            action("Activate Membership")
            {
                Caption = 'Activate Membership';
                Enabled = NeedsActivation;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin

                    //-MM1.22 [278175]
                    ActivateMembership ();

                    //+MM1.22 [278175]
                end;
            }
            action("Add Guardian")
            {
                Caption = 'Add Guardian';
                Ellipsis = true;
                Image = ChangeCustomer;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AddMembershipGuardian ();
                    CurrPage.Update (false);
                end;
            }
            action(Profiles)
            {
                Caption = 'Profiles';
                Image = Answers;
                Promoted = true;

                trigger OnAction()
                begin
                    ContactQuestionnaire ();
                end;
            }
            action(PrintCard)
            {
                Caption = 'Print Member Card';
                Ellipsis = true;
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "MM Membership Management";
                    MemberCardEntryNo: Integer;
                begin
                    //-MM1.22 [289434]
                    if (Confirm (CONFIRM_PRINT, true, StrSubstNo (CONFIRM_PRINT_FMT, "External Member No.", "Display Name"))) then begin
                      //MemberRetailIntegration.PrintMemberCard ("Entry No.", MembershipManagement.GetMemberCardEntryNo ("Entry No.", TODAY));
                      MemberCardEntryNo := CurrPage.MemberCardsSubpage.PAGE.GetCurrentEntryNo ();
                      MemberRetailIntegration.PrintMemberCard ("Entry No.", MemberCardEntryNo);
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "MM Membership Role";
        MembershipEntry: Record "MM Membership Entry";
        MembershipManagement: Codeunit "MM Membership Management";
        ValidFrom2: Date;
        ValidUntil2: Date;
        RemainAmt: Decimal;
        OrigAmt: Decimal;
        RemainingAmount: Decimal;
        DueAmount: Decimal;
        DueDate: Date;
    begin
        Clear (Membership);
        ValidFromDate := 0D;
        ValidUntilDate := 0D;

        if (GMembershipEntryNo <> 0) then
          MembershipRole.SetFilter ("Membership Entry No.", '=%1', GMembershipEntryNo);

        MembershipRole.SetFilter ("Member Entry No.", '=%1', "Entry No.");
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.FindFirst ()) then begin
          Membership.Get (MembershipRole."Membership Entry No.");

          Membership.CalcFields ("Remaining Points");
          RemainingPoints := Membership."Remaining Points";

          MembershipRoleDisplay.Get (MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.");
          MembershipRoleDisplay.CalcFields ("GDPR Approval");

          MembershipManagement.GetMembershipMaxValidUntilDate (MembershipRole."Membership Entry No.", ValidUntilDate);

          if (ValidUntilDate <> 0D) then
            IsAboutToExpire := ((CalcDate ('<-1M>', ValidUntilDate) < Today) and (ValidUntilDate > Today));

          if (IsAboutToExpire) then begin
            MembershipManagement.GetMembershipValidDate (MembershipRole."Membership Entry No.", CalcDate ('<+1D>', ValidUntilDate), ValidFrom2, ValidUntil2);

            if (ValidUntil2 > ValidUntilDate) then begin
              ValidUntilDate := ValidUntil2;
              IsAboutToExpire := false;
            end;

          end;

          if (ValidUntilDate < Today) then
            UntilDateAttentionAccent := true;

          if (IsAboutToExpire) then
            UntilDateAttentionAccent := true;

          OrigAmt := 0;
          RemainAmt := 0;
          MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
          if (MembershipEntry.FindSet ()) then begin
            repeat
              if (MembershipManagement.CalculateRemainingAmount (MembershipEntry, OrigAmt, RemainAmt, DueDate)) then begin
                if (DueDate < Today) then
                  DueAmount += RemainAmt
                else
                  RemainingAmount += RemainAmt;
              end;
            until (MembershipEntry.Next () = 0);
          end;
          AccentuateDueAmount := (DueAmount > 0);
          RemainingAmountText := StrSubstNo ('%1 / %2', Format (RemainingAmount,0, '<Precision,2:2><Integer><Decimals>'), Format (DueAmount, 0, '<Precision,2:2><Integer><Decimals>'));

        end;

        if (Birthday <> 0D) then
          IsBirthday := ((Date2DMY (Birthday,1 ) = Date2DMY (Today, 1)) and (Date2DMY (Birthday, 2) = Date2DMY (Today,2 )));

        IsInvalid := (Blocked);
    end;

    var
        Membership: Record "MM Membership";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        IsInvalid: Boolean;
        IsBirthday: Boolean;
        IsAboutToExpire: Boolean;
        UntilDateAttentionAccent: Boolean;
        NeedsActivation: Boolean;
        GMembershipEntryNo: Integer;
        RemainingPoints: Integer;
        NO_QUESTIONNAIR: Label 'The profile questionnair is not available right now.';
        MembershipRoleDisplay: Record "MM Membership Role";
        RemainingAmountText: Text[50];
        AccentuateDueAmount: Boolean;
        CONFIRM_PRINT: Label 'Do you want to print a member account card for %1?';
        CONFIRM_PRINT_FMT: Label '[%1] - %2';
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";

    procedure SetMembershipEntryNo(MembershipEntryNo: Integer)
    begin

        GMembershipEntryNo := MembershipEntryNo;
        Membership.Get (MembershipEntryNo);
    end;

    local procedure AddMembershipGuardian()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        ResponseMessage: Text;
    begin

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.SetAddMembershipGuardianMode ();
        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();
        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);
          MembershipManagement.AddGuardianMember (Membership."Entry No.", MemberInfoCapture."Guardian External Member No.", MemberInfoCapture."GDPR Approval");

        end;
    end;

    local procedure ActivateMembership()
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipEntry.IsEmpty ()) then begin
          MembershipSalesSetup.SetFilter ("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
          MembershipSalesSetup.SetFilter ("Membership Code", '=%1', Membership."Membership Code");
          MembershipSalesSetup.SetFilter (Blocked, '=%1', false);
          MembershipSalesSetup.FindFirst ();

          MemberInfoCapture.Init;
          MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

          MembershipManagement.AddMembershipLedgerEntry_NEW (Membership."Entry No.", Membership."Issued Date", MembershipSalesSetup, MemberInfoCapture);

        end;

        MembershipManagement.ActivateMembershipLedgerEntry (Membership."Entry No.", Today);
    end;

    local procedure ContactQuestionnaire()
    var
        ProfileManagement: Codeunit ProfileManagement;
        MembershipRole: Record "MM Membership Role";
        Contact: Record Contact;
    begin

        if (not MembershipRole.Get (GMembershipEntryNo, Rec."Entry No.")) then
          Error (NO_QUESTIONNAIR);

        if (not Contact.Get (MembershipRole."Contact No.")) then
          Error (NO_QUESTIONNAIR);

        ProfileManagement.ShowContactQuestionnaireCard (Contact, '', 0);
    end;
}

