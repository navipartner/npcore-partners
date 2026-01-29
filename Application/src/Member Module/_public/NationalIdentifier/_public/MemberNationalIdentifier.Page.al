page 6150916 "NPR MemberNationalIdentifier"
{
    PageType = StandardDialog;
    UsageCategory = None;
    InstructionalText = 'National Identifier details';
    Caption = 'National Identifier';

    layout
    {
        area(Content)
        {
            field(NationalIdentifierType; _NationalIdentifierType)
            {
                Caption = 'Type';
                ToolTip = 'Specifies the value of the National Identifier Type field';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnValidate()
                begin

                    _NationalIdentifierInterface := _NationalIdentifierType;
                    _ExpectedInput := _NationalIdentifierInterface.ExpectedInputExample();
                    _ErrorMessage := '';

                    if (_NationalIdentifierValue = '') then
                        exit;

                    if (not _NationalIdentifierInterface.TryParse(_NationalIdentifierValue, _NationalIdentifierCanonical, _ErrorMessage)) then
                        exit;

                    _NationalIdentifierValue := _NationalIdentifierInterface.ShowUnMasked(_NationalIdentifierCanonical);
                end;
            }

            field(NationalIdentifierHelpText; _ExpectedInput)
            {
                Caption = 'Example';
                ToolTip = 'Format example of the selected National Identifier type';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
            }

            group(Details)
            {

                field(DisplayName; _DisplayName)
                {
                    Caption = 'Member';
                    ToolTip = 'Display name of the member';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }


                field(NationalIdentifierValue; _NationalIdentifierValue)
                {
                    Caption = 'National Identifier';
                    ToolTip = 'Specifies the value of the National Identifier field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        _NationalIdentifierInterface := _NationalIdentifierType;
                        if (_NationalIdentifierInterface.TryParse(_NationalIdentifierValue, _NationalIdentifierCanonical, _ErrorMessage)) then
                            _NationalIdentifierValue := _NationalIdentifierInterface.ShowUnMasked(_NationalIdentifierCanonical);
                    end;
                }

                field(ValidationMessage; _ErrorMessage)
                {
                    Caption = 'Validation Message';
                    ToolTip = 'Displays validation messages for the National Identifier';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                    StyleExpr = (_ErrorMessage <> '');
                    Style = Attention;
                }

            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Member: Record "NPR MM Member";
    begin
        if (CloseAction = CloseAction::OK) then begin
            if (not _NationalIdentifierInterface.TryParse(_NationalIdentifierValue, _NationalIdentifierCanonical, _ErrorMessage)) then
                exit(false);

            Member.GetBySystemId(_MemberId);
            Member.NationalIdentifierType := _NationalIdentifierType;
            Member."Social Security No." := _NationalIdentifierCanonical;
            Member.Modify();
        end;

        exit(true);
    end;

    var
        _NationalIdentifierInterface: Interface "NPR NationalIdentifierIface";
        _MemberId: Guid;
        _DisplayName: Text;
        _NationalIdentifierType: Enum "NPR NationalIdentifierType";
        _NationalIdentifierValue: Text[30];
        _NationalIdentifierCanonical: Text[30];
        _ErrorMessage: Text;
        _ExpectedInput: Text;


    internal procedure SetMember(var Member: Record "NPR MM Member")
    begin
        _MemberId := Member.SystemId;
        _DisplayName := Member."Display Name";
        _NationalIdentifierType := ValidateType(Member.NationalIdentifierType);
        _NationalIdentifierCanonical := Member."Social Security No.";

        _NationalIdentifierInterface := _NationalIdentifierType;
        _NationalIdentifierValue := _NationalIdentifierInterface.ShowUnMasked(_NationalIdentifierCanonical);
        _ExpectedInput := _NationalIdentifierInterface.ExpectedInputExample();
    end;

    local procedure ValidateType(Type: Enum "NPR NationalIdentifierType"): Enum "NPR NationalIdentifierType"
    begin
        if (Type.Ordinals.Contains(Type.AsInteger())) then
            Exit(Type);

        exit(Enum::"NPR NationalIdentifierType"::NONE);
    end;
}