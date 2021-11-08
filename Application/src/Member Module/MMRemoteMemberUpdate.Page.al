page 6059802 "NPR MM Remote Member Update"
{
    PageType = StandardDialog;
    UsageCategory = None;
    SourceTable = "NPR MM Member";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Remote Member Update';

    layout
    {
        area(Content)
        {
            group(General)
            {

                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateFirstName;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ToolTip = 'Specifies the value of the Middle Name field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateMiddleName;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateLastName;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdatePhoneNo;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateEmail;
                }
            }

            group(Additional)
            {

                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateAddress;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateZipCode;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateCity;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateCountryCode;
                }
                field(Gender; Rec.Gender)
                {
                    ToolTip = 'Specifies the value of the Gender field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateGender;
                }
                field(Birthday; Rec.Birthday)
                {
                    ToolTip = 'Specifies the value of the Birthday field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateBirthday;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the value of the Store Code field.';
                    ApplicationArea = NPRRetail;
                    Editable = _UpdateStoreCode;
                }
            }
        }
    }

    var
        _MemberEntryNo: Integer;
        _MembershipEntryNo: Integer;
        _UpdateEmail: Boolean;
        _UpdatePhoneNo: Boolean;
        _UpdateFirstName: Boolean;
        _UpdateMiddleName: Boolean;
        _UpdateLastName: Boolean;
        _UpdateAddress: Boolean;
        _UpdateCity: Boolean;
        _UpdateCountryCode: Boolean;
        _UpdateZipCode: Boolean;
        _UpdateGender: Boolean;
        _UpdateBirthday: Boolean;
        _UpdateStoreCode: Boolean;


    trigger OnOpenPage()
    begin
        EnableFieldsToEdit(_MemberEntryNo);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RequestMemberFieldUpdate: Record "NPR MM Request Member Update";
        Member: Record "NPR MM Member";
        MemberFieldUpdateMgr: Codeunit "NPR MM Request Member Upd Mgr";
    begin
        if (CloseAction <> Action::LookupOK) then exit;

        RequestMemberFieldUpdate.SetFilter("Member Entry No.", '=%1', _MemberEntryNo);
        RequestMemberFieldUpdate.SetFilter(Handled, '=%1', false);
        if (not RequestMemberFieldUpdate.FindSet()) then
            exit;
        Member.Get(_MemberEntryNo);

        repeat
            case (RequestMemberFieldUpdate."Field No.") OF
                Rec.FieldNo("First Name"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."First Name", Rec."First Name", _MembershipEntryNo);
                Rec.FieldNo("Middle Name"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."Middle Name", Rec."Middle Name", _MembershipEntryNo);
                Rec.FieldNo("Last Name"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."Last Name", Rec."Last Name", _MembershipEntryNo);
                Rec.FieldNo("Phone No."):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."Phone No.", Rec."Phone No.", _MembershipEntryNo);
                Rec.FieldNo(Address):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member.Address, Rec.Address, _MembershipEntryNo);
                Rec.FieldNo("Post Code Code"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."Post Code Code", Rec."Post Code Code", _MembershipEntryNo);
                Rec.FieldNo(City):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member.City, Rec.City, _MembershipEntryNo);
                Rec.FieldNo("Country Code"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."Country Code", Rec."Country Code", _MembershipEntryNo);
                Rec.FieldNo(Gender):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", FORMAT(Member.Gender, 0, 9), FORMAT(Rec.Gender, 0, 9), _MembershipEntryNo);
                Rec.FieldNo(Birthday):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", FORMAT(Member.Birthday, 0, 9), FORMAT(Rec.Birthday, 0, 9), _MembershipEntryNo);
                Rec.FieldNo("E-Mail Address"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."E-Mail Address", Rec."E-Mail Address", _MembershipEntryNo);
                Rec.FieldNo("Store Code"):
                    MemberFieldUpdateMgr.UpdateMemberField(RequestMemberFieldUpdate."Entry No.", Member."Store Code", Rec."Store Code", _MembershipEntryNo);
            end;
        until (RequestMemberFieldUpdate.Next() = 0);
    end;

    procedure SetMembershipAndMember(MembershipEntryNo: Integer; MemberEntryNo: Integer): Boolean
    var
        Member: Record "NPR MM Member";
    begin
        _MembershipEntryNo := MembershipEntryNo;
        _MemberEntryNo := MemberEntryNo;

        if (not Member.Get(_MemberEntryNo)) then
            exit(false);
    end;

    local procedure IsFieldEditable(FieldNo: Integer): Boolean
    var
        RequestMemberFieldUpdate: Record "NPR MM Request Member Update";
    begin
        RequestMemberFieldUpdate.SetFilter("Member Entry No.", '=%1', _MemberEntryNo);
        RequestMemberFieldUpdate.SetFilter("Field No.", '=%1', FieldNo);
        RequestMemberFieldUpdate.SetFilter(Handled, '=%1', false);

        exit(not RequestMemberFieldUpdate.IsEmpty());
    end;

    local procedure EnableFieldsToEdit(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
    begin
        Member.Get(MemberEntryNo);

        Rec.TransferFields(Member, true);
        Rec.Insert();

        _UpdateEmail := IsFieldEditable(Rec.FieldNo("E-Mail Address"));
        _UpdatePhoneNo := IsFieldEditable(Rec.FieldNo("Phone No."));
        _UpdateFirstName := IsFieldEditable(Rec.FieldNo("First Name"));
        _UpdateMiddleName := IsFieldEditable(Rec.FieldNo("Middle Name"));
        _UpdateLastName := IsFieldEditable(Rec.FieldNo("Last Name"));
        _UpdateAddress := IsFieldEditable(Rec.FieldNo(Address));
        _UpdateCity := IsFieldEditable(Rec.FieldNo(City));
        _UpdateCountryCode := IsFieldEditable(Rec.FieldNo("Country Code"));
        _UpdateZipCode := IsFieldEditable(Rec.FieldNo("Post Code Code"));
        _UpdateGender := IsFieldEditable(Rec.FieldNo(Gender));
        _UpdateBirthday := IsFieldEditable(Rec.FieldNo(Birthday));
        _UpdateStoreCode := IsFieldEditable(Rec.FieldNo("Store Code"));

    end;
}