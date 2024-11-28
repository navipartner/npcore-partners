tableextension 6014473 "NPR Picture Entity" extends "Picture Entity"
{
    procedure NPRLoadDataWithParentType(IdFilter: Text; ParentType: Enum "Picture Entity Parent Type")
    var
        MediaID: Guid;
    begin
        Id := IdFilter;
        "Parent Type" := ParentType;
        MediaID := NPRGetMediaIDWithParentType(Id, ParentType);
        NPRSetValuesFromMediaID(MediaID);
    end;

    local procedure NPRGetMediaIDWithParentType(ParentId: Guid; ParentType: Enum "Picture Entity Parent Type"): Guid
    var
        Customer: Record Customer;
        Item: Record Item;
        Vendor: Record Vendor;
        Employee: Record Employee;
#if not BC17
        Contact: Record Contact;
#endif
        MediaID: Guid;
        EntityNotSupportedErr: Label 'Given parent type is not supported.';
    begin
        case ParentType of
            "Parent Type"::Item:
                if Item.GetBySystemId(ParentId) then
                    if Item.Picture.Count > 0 then
                        MediaID := Item.Picture.Item(1);
            "Parent Type"::Customer:
                if Customer.GetBySystemId(ParentId) then
                    MediaID := Customer.Image.MediaId;
            "Parent Type"::Vendor:
                if Vendor.GetBySystemId(ParentId) then
                    MediaID := Vendor.Image.MediaId;
            "Parent Type"::Employee:
                if Employee.GetBySystemId(ParentId) then
                    MediaID := Employee.Image.MediaId;
#if not BC17
            "Parent Type"::Contact:
                if Contact.GetBySystemId(ParentId) then
                    MediaID := Contact.Image.MediaId;
#endif
            else
                Error(EntityNotSupportedErr);
        end;
        exit(MediaID);
    end;

    local procedure NPRSetValuesFromMediaID(MediaID: Guid)
    var
        TenantMedia: Record "Tenant Media";
    begin
        if IsNullGuid(MediaID) then
            exit;

        TenantMedia.SetAutoCalcFields(Content);
        if not TenantMedia.Get(MediaID) then
            exit;

        "Mime Type" := TenantMedia."Mime Type";
        Width := TenantMedia.Width;
        Height := TenantMedia.Height;

        Content := TenantMedia.Content;
    end;
}