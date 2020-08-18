codeunit 6151186 "MM NpXml Membership Trigger"
{
    // MM1.45/TSA /20200710 CASE 413622 Initial Version


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151553, 'OnSetupGenericParentTable', '', true, true)]
    local procedure IsContactMembershipInfoComplete(NpXmlTemplateTrigger: Record "NpXml Template Trigger";ChildLinkRecRef: RecordRef;var ParentRecRef: RecordRef;var Handled: Boolean)
    var
        Contact: Record Contact;
        TempContact: Record Contact temporary;
        ContactBusinessRelation: Record "Contact Business Relation";
        TempContactBusinessRelation: Record "Contact Business Relation" temporary;
        Customer: Record Customer;
    begin

        if Handled then
          exit;

        if (not IsSubscriber (NpXmlTemplateTrigger, 'IsContactMembershipInfoComplete')) then
          exit;

        Handled := true;
        DATABASE.SelectLatestVersion ();

        case NpXmlTemplateTrigger."Parent Table No." of
          DATABASE::Contact :
            begin
              ParentRecRef.GetTable(TempContact);
              case ChildLinkRecRef.Number of
                DATABASE::Contact :
                  begin
                    ChildLinkRecRef.SetTable (Contact);
                    if (not IsValidContact (Contact."No.")) then
                      exit;
                    ParentRecRef.GetTable(Contact);
                  end;

                DATABASE::"Contact Business Relation" :
                  begin
                    ChildLinkRecRef.SetTable (ContactBusinessRelation);
                    if (not IsValidContact (ContactBusinessRelation."Contact No.")) then
                      exit;
                    Contact.Get (ContactBusinessRelation."Contact No.");
                    ParentRecRef.GetTable (Contact);
                  end;
                else begin
                  Handled := false;
                  ParentRecRef.Close ();
                end;
              end;
            end;

          DATABASE::"Contact Business Relation" :
            begin
              ParentRecRef.GetTable (TempContactBusinessRelation);
              case ChildLinkRecRef.Number of
                DATABASE::Customer :
                  begin
                    ChildLinkRecRef.SetTable (Customer);
                    ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
                    ContactBusinessRelation.SetFilter ("No.", '=%1', Customer."No.");
                    if (ContactBusinessRelation.FindSet ()) then begin
                      repeat
                        if (IsValidContact (ContactBusinessRelation."Contact No.")) then
                          ParentRecRef.GetTable (ContactBusinessRelation);

                      until (ContactBusinessRelation.Next () = 0);
                    end;
                  end;
                DATABASE::Contact :
                  begin
                    ChildLinkRecRef.SetTable (Contact);
                    if (not IsValidContact (Contact."No.")) then
                      exit;
                    ContactBusinessRelation.SetFilter ("Contact No.", '=%1', Contact."No.");
                    ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
                    if (ContactBusinessRelation.FindLast ()) then
                      ParentRecRef.GetTable (ContactBusinessRelation);
                  end;

                else begin
                  Handled := false;
                  ParentRecRef.Close ();
                end;
              end;
            end;


          else
            Handled := false;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151553, 'OnSetupGenericParentTable', '', true, true)]
    local procedure IsMembershipValidForExport(NpXmlTemplateTrigger: Record "NpXml Template Trigger";ChildLinkRecRef: RecordRef;var ParentRecRef: RecordRef;var Handled: Boolean)
    var
        Membership: Record "MM Membership";
        TempMembership: Record "MM Membership" temporary;
        MembershipRole: Record "MM Membership Role";
        TempMembershipRole: Record "MM Membership Role" temporary;
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
    begin

        if Handled then
          exit;

        if (not IsSubscriber (NpXmlTemplateTrigger, 'IsMembershipValidForExport')) then
          exit;

        Handled := true;
        DATABASE.SelectLatestVersion ();

        case NpXmlTemplateTrigger."Parent Table No." of
          DATABASE::"MM Membership" :
            begin
              ParentRecRef.GetTable (TempMembership);
              case ChildLinkRecRef.Number of
                DATABASE::"MM Membership" :
                  begin
                    ChildLinkRecRef.SetTable (Membership);
                    if (not IsMembershipReadyForExportWorker (Membership."Entry No.")) then
                      exit;
                    //TempMembership.TRANSFERFIELDS (Membership, TRUE);
                    //TempMembership.INSERT;
                    ParentRecRef.GetTable (Membership);
                  end;

                DATABASE::"MM Membership Role" :
                  begin
                    ChildLinkRecRef.SetTable (MembershipRole);
                    if (not IsMembershipReadyForExportWorker (MembershipRole."Membership Entry No.")) then
                      exit;
                    Membership.Get (MembershipRole."Membership Entry No.");
                    //TempMembership.TRANSFERFIELDS (Membership, TRUE);
                    //TempMembership.INSERT;
                    ParentRecRef.GetTable (Membership);
                  end;

                else begin
                  Handled := false;
                  ParentRecRef.Close ();
                  exit;
                end;
              end;
            end;

          DATABASE::"MM Membership Role" :
            begin
              ParentRecRef.GetTable (TempMembershipRole);

              case ChildLinkRecRef.Number of
                DATABASE::"MM Member" :
                  begin
                    ChildLinkRecRef.SetTable (Member);
                    MembershipRole.SetFilter ("Member Entry No.", '=%1', Member."Entry No.");
                    if (MembershipRole.FindSet ()) then begin
                      repeat
                        if (IsMembershipReadyForExportWorker (MembershipRole."Membership Entry No.")) then begin
                          //TempMembershipRole.TRANSFERFIELDS (MembershipRole, TRUE);
                          //TempMembershipRole.INSERT;
                          ParentRecRef.GetTable (MembershipRole);
                        end;
                      until (MembershipRole.Next () = 0);
                    end;
                  end;

                DATABASE::"MM Member Card" :
                  begin
                    ChildLinkRecRef.SetTable (MemberCard);
                    if (IsMembershipReadyForExportWorker (MemberCard."Membership Entry No.")) then begin
                      MembershipRole.SetFilter ("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
                      MembershipRole.SetFilter ("Member Entry No.", '=%1', MemberCard."Member Entry No.");
                      if (MembershipRole.FindFirst ()) then begin
                        //TempMembershipRole.TRANSFERFIELDS (MembershipRole, TRUE);
                        //TempMembershipRole.INSERT;
                        ParentRecRef.GetTable (MembershipRole);
                      end;
                    end;
                  end;

                else begin
                  Handled := false;
                  ParentRecRef.Close ();
                  exit;
                end;
              end;
            end;

          else begin
            Handled := false;
            exit;
          end;

        end;
    end;

    local procedure IsSubscriber(NpXmlTemplateTrigger: Record "NpXml Template Trigger";FunctionName: Text): Boolean
    begin

        if (NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> CurrCodeunitId()) then
          exit(false);

        exit (NpXmlTemplateTrigger."Generic Parent Function" = FunctionName);
    end;

    local procedure IsValidContact(ContactNo: Code[20]): Boolean
    var
        MembershipRole: Record "MM Membership Role";
        Membership: Record "MM Membership";
    begin

        if (ContactNo = '') then
          exit (false);

        if (not MembershipRole.SetCurrentKey ("Contact No.")) then ;
        MembershipRole.SetFilter ("Contact No.", '=%1', ContactNo);
        if (not MembershipRole.FindFirst ()) then
          exit (true); // This contact does not have member related data, so we can sync it

        exit (IsMembershipReadyForExportWorker (MembershipRole."Membership Entry No."));
    end;

    local procedure IsMembershipReadyForExportWorker(MembershipEntryNo: Integer) ReadyToExport: Boolean
    var
        MembershipEntry: Record "MM Membership Entry";
    begin

        if (MembershipEntryNo = 0) then
          exit (false);

        if (not MembershipEntry.SetCurrentKey ("Membership Entry No.")) then ;

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        ReadyToExport := MembershipEntry.FindFirst ();
        exit (ReadyToExport);
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"MM NpXml Membership Trigger");
    end;
}

