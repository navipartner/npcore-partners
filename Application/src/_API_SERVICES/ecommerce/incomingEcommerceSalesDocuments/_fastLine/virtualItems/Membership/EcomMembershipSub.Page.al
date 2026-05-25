#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248183 "NPR Ecom Membership Sub"
{
    Caption = 'Memberships';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR MM Membership";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the external membership number presented to the customer.';
                }
                field(MemberDisplayName; _DisplayName)
                {
                    Caption = 'Member Display Name';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the display name of the admin/guardian member linked to the membership.';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the membership product code.';
                }
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the membership community.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer linked to the membership, if any.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the membership is blocked.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenMembership)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected membership to see full details, ledger entries and member info.';

                trigger OnAction()
                var
                    EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
                begin
                    EcomCreateMMShipImpl.OpenMembershipCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if not _DisplayNameByEntryNo.Get(Rec."Entry No.", _DisplayName) then
            _DisplayName := '';
    end;

    var
        _DisplayNameByEntryNo: Dictionary of [Integer, Text[100]];
        _DisplayName: Text[100];

    /// <summary>
    /// Clears the temp buffer. Called by the parent page before enqueueing a background task or on task error.
    /// </summary>
    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        Clear(_DisplayNameByEntryNo);
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Populates the temp buffer from a JSON array payload produced by the parent's background task.
    /// </summary>
    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        MembershipsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and MembershipsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(MembershipsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(MembershipsJson: JsonArray)
    var
        MembershipToken: JsonToken;
        MembershipObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
        ParsedDisplayName: Text[100];
    begin
        foreach MembershipToken in MembershipsJson do begin
            MembershipObj := MembershipToken.AsObject();
            Rec.Init();
            ParsedDisplayName := '';
            if MembershipObj.Get('No', FieldToken) then
                Rec."Entry No." := FieldToken.AsValue().AsInteger();
            if MembershipObj.Get('Ext', FieldToken) then
                Rec."External Membership No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."External Membership No."));
            if MembershipObj.Get('Code', FieldToken) then
                Rec."Membership Code" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Membership Code"));
            if MembershipObj.Get('Comm', FieldToken) then
                Rec."Community Code" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Community Code"));
            if MembershipObj.Get('Cust', FieldToken) then
                Rec."Customer No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Customer No."));
            if MembershipObj.Get('Blk', FieldToken) then
                Rec.Blocked := FieldToken.AsValue().AsBoolean();
            if MembershipObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            if MembershipObj.Get('Disp', FieldToken) then
                ParsedDisplayName := CopyStr(FieldToken.AsValue().AsText(), 1, 100);
            Rec.Insert(false, true);  // (RunTrigger, InsertWithSystemId) — preserve SystemId for the Open action.
            _DisplayNameByEntryNo.Set(Rec."Entry No.", ParsedDisplayName);
        end;
    end;
}
#endif
