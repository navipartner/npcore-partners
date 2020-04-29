page 6060073 "MM Membership Alteration Jnl"
{
    // MM1.25/TSA /20171213 CASE 299783 Initial Version
    // MM1.26/TSA /20180131 CASE 303546 Added Customer No as alternative search term in external membership no field
    // MM1.34/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.43/TSA /20200402 CASE 398329 Added action for batch renew

    Caption = 'Membership Alteration Journal';
    PageType = List;
    SourceTable = "MM Member Info Capture";
    SourceTableView = WHERE("Source Type"=CONST(ALTERATION_JNL));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Type;AlterationOption)
                {
                    OptionCaption = ' ,Regret,Renew,Upgrade,Extend,Cancel';
                }
                field("External Membership No.";"External Membership No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipLookup ();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMembershipNo ("External Membership No.");
                    end;
                }
                field("Membership Code";"Membership Code")
                {
                    Editable = false;
                }
                field("Item No.";"Item No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        ItemLookup ();
                    end;

                    trigger OnValidate()
                    begin

                        SetItemNo ("Item No.");
                    end;
                }
                field("Document Date";"Document Date")
                {
                }
                field(Description;Description)
                {
                }
                field("Response Status";"Response Status")
                {

                    trigger OnValidate()
                    begin

                        "Response Message" := '';
                    end;
                }
                field("Response Message";"Response Message")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Check)
            {
                Caption = 'Check';
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    AlterMemberships (false);
                end;
            }
            action("Check and Execute")
            {
                Caption = 'Check and Execute';
                Ellipsis = true;
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    AlterMemberships (true);
                end;
            }
            action("Batch Renew")
            {
                Caption = 'Batch Renew';
                Ellipsis = true;
                Image = CalculatePlan;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    BatchRenewReport: Report "MM Membership Batch Renew";
                begin

                    BatchRenewReport.LaunchAlterationJnlPage (false);
                    BatchRenewReport.RunModal ();
                    CurrPage.Update (false);
                end;
            }
        }
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = Setup;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Setup";
                RunPageLink = Code=FIELD("Membership Code");
            }
            action("Membership Card")
            {
                Caption = 'Membership Card';
                Image = Customer;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Card";
                RunPageLink = "Entry No."=FIELD("Membership Entry No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        case "Information Context" of
          "Information Context"::REGRET : AlterationOption := AlterationOption::REGRET;
          "Information Context"::RENEW  : AlterationOption := AlterationOption::RENEW;
          "Information Context"::UPGRADE : AlterationOption := AlterationOption::UPGRADE;
          "Information Context"::EXTEND : AlterationOption := AlterationOption::EXTEND;
          "Information Context"::CANCEL : AlterationOption := AlterationOption::CANCEL;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        SetInformationContext (AlterationOption);
    end;

    trigger OnModifyRecord(): Boolean
    begin

        SetInformationContext (AlterationOption);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Source Type" := "Source Type"::ALTERATION_JNL;
        "Document Date" := WorkDate;
    end;

    var
        AlterationOption: Option " ",REGRET,RENEW,UPGRADE,EXTEND,CANCEL;
        CONFIRM_EXECUTE: Label '%1 lines are selected. Are you sure you want to make the selected changes? ';

    local procedure SetInformationContext(pType: Option)
    begin

        case pType of
          AlterationOption::REGRET : "Information Context" := "Information Context"::REGRET;
          AlterationOption::RENEW : "Information Context" := "Information Context"::RENEW;
          AlterationOption::UPGRADE : "Information Context" := "Information Context"::UPGRADE;
          AlterationOption::EXTEND : "Information Context" := "Information Context"::EXTEND;
          AlterationOption::CANCEL : "Information Context" := "Information Context"::CANCEL;
        end;
    end;

    local procedure MembershipLookup()
    var
        MembershipListPage: Page "MM Memberships";
        Membership: Record "MM Membership";
        PageAction: Action;
    begin

        Membership.SetFilter (Blocked, '=%1', false);
        MembershipListPage.SetTableView (Membership);
        MembershipListPage.LookupMode (true);
        PageAction := MembershipListPage.RunModal();

        if (PageAction <> ACTION::LookupOK) then
          exit;

        MembershipListPage.GetRecord (Membership);
        SetExternalMembershipNo (Membership."External Membership No.");
    end;

    local procedure ItemLookup()
    var
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        MembershipAlterationPage: Page "MM Membership Alteration";
        PageAction: Action;
    begin

        MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', GetAlterationType (AlterationOption));
        TestField ("Membership Code");
        MembershipAlterationSetup.SetFilter ("From Membership Code", '=%1', "Membership Code");
        MembershipAlterationPage.SetTableView (MembershipAlterationSetup);
        MembershipAlterationPage.LookupMode (true);
        PageAction := MembershipAlterationPage.RunModal ();

        if (PageAction <> ACTION::LookupOK) then
          exit;

        MembershipAlterationPage.GetRecord (MembershipAlterationSetup);
        SetItemNo (MembershipAlterationSetup."Sales Item No.");
    end;

    local procedure SetExternalMembershipNo(pExternalMembershipNo: Code[20])
    var
        Membership: Record "MM Membership";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        if (pExternalMembershipNo = '') then begin
          "Membership Entry No." := 0;
          "External Membership No." := pExternalMembershipNo;
          "Membership Code" := '';
          exit;
        end;

        //-MM1.26 [303546]
        Membership.SetFilter ("External Membership No.", '=%1', pExternalMembershipNo);
        //Membership.FINDFIRST ();
        if (not Membership.FindFirst ()) then begin
          Membership.Reset ();
          Membership.SetFilter ("Customer No.", '=%1', pExternalMembershipNo);
          Membership.SetFilter (Blocked, '=%1', false);
          if not (Membership.FindFirst ()) then begin
            Membership.Reset;
            Membership.SetFilter ("External Membership No.", '=%1', pExternalMembershipNo);
            Membership.FindFirst ();
          end;
        end;
        //+MM1.26 [303546]

        "Membership Entry No." := Membership."Entry No.";
        "External Membership No." := Membership."External Membership No.";
        "Membership Code" := Membership."Membership Code";

        if ("Membership Code" <> '') then begin
          MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', GetAlterationType (AlterationOption));
          MembershipAlterationSetup.SetFilter ("From Membership Code", '=%1', "Membership Code");
          if (MembershipAlterationSetup.Count() = 1) then begin
            MembershipAlterationSetup.FindFirst ();
            SetItemNo (MembershipAlterationSetup."Sales Item No.");
          end;
        end;
    end;

    local procedure SetItemNo(ItemNo: Code[20])
    var
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        "Item No." := ItemNo;
        Description := MembershipAlterationSetup.Description;
        if (ItemNo = '') then
          exit;

        MembershipAlterationSetup.Get (GetAlterationType (AlterationOption), "Membership Code", ItemNo);
        "Item No." := ItemNo;
        Description := MembershipAlterationSetup.Description;
    end;

    local procedure GetAlterationType(pAlterationOption: Option): Integer
    var
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        case pAlterationOption of
          AlterationOption::RENEW : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::RENEW;
          AlterationOption::UPGRADE : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::UPGRADE;
          AlterationOption::EXTEND : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::EXTEND;
          AlterationOption::CANCEL : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::CANCEL;
          AlterationOption::REGRET : MembershipAlterationSetup."Alteration Type" := MembershipAlterationSetup."Alteration Type"::REGRET;
          else
            Error ('Type must be selected.');
        end;

        exit (MembershipAlterationSetup."Alteration Type");
    end;

    local procedure AlterMemberships(CheckAndExecute: Boolean)
    var
        AlterationJnlMgmt: Codeunit "MM Alteration Jnl Mgmt";
        MemberInfoCapture: Record "MM Member Info Capture";
        SelectionCount: Integer;
    begin

        CurrPage.SetSelectionFilter (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Source Type", '=%1', MemberInfoCapture."Source Type"::ALTERATION_JNL);
        if (MemberInfoCapture.FindSet ()) then begin

          SelectionCount := MemberInfoCapture.Count();
          AlterationJnlMgmt.SetRequestUserConfirmation (SelectionCount = 1);

          if ((SelectionCount > 1) and (CheckAndExecute)) then
            if (not Confirm (CONFIRM_EXECUTE, true, SelectionCount)) then
              Error ('');

          repeat

            if (MemberInfoCapture."Response Status" in ["Response Status"::REGISTERED, "Response Status"::FAILED]) then begin
              MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
              AlterationJnlMgmt.AlterMembership (MemberInfoCapture);
              MemberInfoCapture.Modify();
              AlterationJnlMgmt.SetRequestUserConfirmation (false);
            end;

            if (CheckAndExecute) then begin
              if (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::READY) then begin
                AlterationJnlMgmt.AlterMembership (MemberInfoCapture);
                MemberInfoCapture.Modify();
              end;

              if (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::COMPLETED) then
                MemberInfoCapture.Delete();
            end;

          until (MemberInfoCapture.Next() = 0);
        end;

        CurrPage.Update(false);
    end;
}

