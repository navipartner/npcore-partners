codeunit 6060142 "MM Loyalty WebService Mgr"
{
    // MM1.19/NPKNAV/20170525  CASE 274690 Transport MM1.20 - 25 May 2017
    // MM1.37/TSA /20190226 CASE 338215 Points for payments refactored
    // MM1.37/TSA /20190226 CASE 338215 Added GetLoyaltyPointsEntries

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet XmlDocument;
        ImportType: Record "Nc Import Type";
        FunctionName: Text[100];
    begin

        if LoadXmlDoc (XmlDoc) then begin
          FunctionName := GetWebserviceFunction ("Import Type");
          case FunctionName of
            'GetLoyaltyPoints'                : GetLoyaltyPoints (XmlDoc, "Document ID");
            'GetLoyaltyPointEntries'          : GetLoyaltyPoints (XmlDoc, "Document ID"); //-+MM1.37 [338215]
            else
              Error ('Implementation for %1 %2 missing in codeunit 6060142', "Import Type", FunctionName);
          end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        MEMBERSHIP_NOT_FOUND: Label 'The membership could not be found using the provided search criteria.';

    local procedure GetLoyaltyPoints(XmlDoc: DotNet XmlDocument;DocumentID: Text[100])
    var
        XmlElement: DotNet XmlElement;
        XmlElementNode: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin

        if IsNull(XmlDoc) then
          exit;

        XmlElement := XmlDoc.DocumentElement;

        if IsNull(XmlElement) then
          exit;

        //-MM1.37 [338215] refactored

        if (not NpXmlDomMgt.FindNodes (XmlElement, 'request', XmlNodeList)) then
          Error ('request node not found.');

        XmlElementNode := XmlNodeList.ItemOf(0);
        DecodeLoyaltyPointsQuery (XmlElementNode, DocumentID);

        //+MM1.37 [338215]
    end;

    local procedure "--Handlers"()
    begin
    end;

    local procedure DecodeLoyaltyPointsQuery(XmlElement: DotNet XmlElement;DocumentID: Text[100]) Imported: Boolean
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        Member: Record "MM Member";
        NotFoundReason: Text;
        IsValid: Boolean;
    begin

        if IsNull(XmlElement) then
          exit(false);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Import Entry Document ID" := DocumentID;
        DeserializeMembershipQuery (XmlElement, MemberInfoCapture);

        if (MemberInfoCapture."External Membership No." <> '') then
          MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtMembershipNo (MemberInfoCapture."External Membership No.");

        if (MemberInfoCapture."External Card No." <> '') then begin
          if (MemberInfoCapture."Member Entry No" = 0) then
            MemberInfoCapture."Membership Entry No." := MembershipManagement.GetMembershipFromExtCardNo(MemberInfoCapture."External Card No.", WorkDate, NotFoundReason);
        end;

        if (MemberInfoCapture."Membership Entry No." = 0) then
          Error (MEMBERSHIP_NOT_FOUND);

        if (not Membership.Get (MemberInfoCapture."Membership Entry No.")) then
          Error (MEMBERSHIP_NOT_FOUND);

        MemberInfoCapture.Modify ();

        exit(true);
    end;

    local procedure "--"()
    begin
    end;

    local procedure DeserializeMembershipQuery(XmlElement: DotNet XmlElement;var MemberInfoCapture: Record "MM Member Info Capture")
    var
        CustomerNo: Code[20];
        Membership: Record "MM Membership";
    begin

        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."External Member No" := NpXmlDomMgt.GetXmlText (XmlElement, 'membernumber', MaxStrLen (MemberInfoCapture."External Member No"), false);
        MemberInfoCapture."External Card No." := NpXmlDomMgt.GetXmlText (XmlElement, 'cardnumber', MaxStrLen (MemberInfoCapture."External Card No."), false);
        MemberInfoCapture."External Membership No." := NpXmlDomMgt.GetXmlText (XmlElement, 'membershipnumber', MaxStrLen (MemberInfoCapture."External Membership No."), false);

        CustomerNo := NpXmlDomMgt.GetXmlText (XmlElement, 'customernumber', 20, false);
        if (CustomerNo <> '') then begin
          Membership.SetFilter ("Customer No.", '=%1', CustomerNo);
          Membership.SetFilter (Blocked, '=%1', false);
          if (Membership.FindFirst ()) then
            MemberInfoCapture."External Member No" := Membership."External Membership No.";
        end;

        MemberInfoCapture.Insert
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear (ImportType);
        ImportType.SetFilter (Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst ()) then ;

        exit (ImportType."Webservice Function");
    end;
}

