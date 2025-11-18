namespace CollectionManagementBlazor.Models;

/// <summary>
/// Base class for view models used in the Blazor UI
/// </summary>
public abstract class BaseViewModel
{
    public bool IsLoading { get; set; }
    public string? ErrorMessage { get; set; }
}

/// <summary>
/// Placeholder for collection-related view models
/// Add specific view models as needed for your application
/// </summary>
public class CollectionViewModel : BaseViewModel
{
    // Add properties as needed
}
