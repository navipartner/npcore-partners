interface "NPR IAF App"
{

#IF NOT BC17
    Access = Internal;
#ENDIF
    /// <summary>
    /// Returns the name of the App which is used by `AFHttpClient` to create the url for the Azure Function
    /// </summary>
    procedure FunctionAppName(): Text;
    /// <summary>
    /// This method should fill in all the names of Azure Function Actions from the Azure function.
    /// that is called.
    /// </summary>
    procedure FunctionActionNames(var fActions: List of [Text]);
    /// <summary>
    /// This returns the current version of the AF. Remember to create a new version if breaking changes occour, and not delete the old one.
    /// as part of the soft upgrade.
    /// </summary>
    procedure FunctionAppVersion(): Integer;
    /// <summary>
    /// This method return the text key value of the Azure Vault Secret, mapping to the API Management Subsription linked to the Azure Function
    /// that is called.
    /// </summary>
    procedure AzureVaultKeyNameForSubscription(): Text;
}