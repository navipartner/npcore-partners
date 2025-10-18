codeunit 6248595 "NPR NPDesignerManifestWebHook"
{
    Access = Internal;
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    [ExternalBusinessEvent('designer_manifest_created', 'Manifest Created', 'Triggered when a NP Designer Manifest has been created', EventCategory::"NPR NPDesigner Manifest", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NPDesignerManifestWebHook", 'X')]
    internal procedure OnManifestCreated(manifestId: Guid)
    begin
    end;


    [ExternalBusinessEvent('designer_manifest_content_added', 'Manifest Content Added', 'Triggered when a NP Designer Manifest has been updated', EventCategory::"NPR NPDesigner Manifest", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NPDesignerManifestWebHook", 'X')]
    internal procedure OnManifestContentAdded(manifestId: Guid; id: Guid; assetTableNumber: Integer; assetId: Guid; assetPublicId: Text[100]; renderWithDesignLayout: Text[40])
    begin
    end;


    [ExternalBusinessEvent('designer_manifest_content_removed', 'Manifest Content Removed', 'Triggered when a NP Designer Manifest has been updated', EventCategory::"NPR NPDesigner Manifest", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NPDesignerManifestWebHook", 'X')]
    internal procedure OnManifestContentRemoved(manifestId: Guid; id: Guid; assetTableNumber: Integer; assetId: Guid)
    begin
    end;


    [ExternalBusinessEvent('designer_manifest_content_changed', 'Manifest Content Changed', 'Triggered when a NP Designer Manifest has been updated', EventCategory::"NPR NPDesigner Manifest", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NPDesignerManifestWebHook", 'X')]
    internal procedure OnManifestContentChange(manifestId: Guid)
    begin
    end;


    [ExternalBusinessEvent('designer_manifest_deleted', 'Manifest Deleted', 'Triggered when a NP Designer Manifest has been deleted', EventCategory::"NPR NPDesigner Manifest", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NPDesignerManifestWebHook", 'X')]
    internal procedure OnManifestDeleted(manifestId: Guid)
    begin
    end;

#else
    internal procedure OnManifestCreated(manifestId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;
    
    internal procedure OnManifestContentAdded(manifestId: Guid; id: Guid; assetTableNumber: Integer; assetId: Guid; assetPublicId: Text[100]; renderWithDesignLayout: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;
    
    internal procedure OnManifestContentRemoved(manifestId: Guid; id: Guid; assetTableNumber: Integer; assetId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;
    
    internal procedure OnManifestContentChange(manifestId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;
    
    internal procedure OnManifestDeleted(manifestId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;
#endif
}