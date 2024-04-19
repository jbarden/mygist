using ArchUnitNET.Domain;
using ArchUnitNET.Fluent;
using ArchUnitNET.Loader;
using FluentAssertions;
using static ArchUnitNET.Fluent.ArchRuleDefinition;

namespace {ArchitectureNamespace};

// https://github.com/TNG/ArchUnitNET
public class ArchitectureLayersShould
{
    private const string UiName = "{UiName}";
    private const string ApiName = "{ApiName}";
    private const string DomainModelName = "{DomainModel}";
    private const string InfrastructureName = "{InfrastructureName}";
    private readonly IObjectProvider<IType> uiLayer;
    private readonly IObjectProvider<IType> apiLayer;
    private readonly IObjectProvider<IType> domainModelLayer;
    private readonly IObjectProvider<IType> infrastructureLayer;
    private readonly ArchUnitNET.Domain.Architecture architecture;

    public ArchitectureLayersShould()
    {
        uiLayer = Types().That().ResideInAssembly(System.Reflection.Assembly.Load(UiName)).As("UI Layer");
        apiLayer = Types().That().ResideInAssembly(System.Reflection.Assembly.Load(ApiName)).As("API Layer");
        domainModelLayer = Types().That().ResideInAssembly(System.Reflection.Assembly.Load(DomainModelName)).As("DomainModel Layer");
        infrastructureLayer = Types().That().ResideInAssembly(System.Reflection.Assembly.Load(InfrastructureName)).As("Infrastructure Layer");
        architecture = new ArchLoader().LoadAssemblies(
            System.Reflection.Assembly.Load(UiName),
            System.Reflection.Assembly.Load(InfrastructureName),
            System.Reflection.Assembly.Load(DomainModelName),
            System.Reflection.Assembly.Load(ApiName))
            .Build();
    }

    [Fact]
    public void NotAllowTheUiToDirectlyDependOnTheapiLayer()
    {
        IArchRule rule = Types().That().Are(uiLayer).Should()
            .NotDependOnAny(apiLayer).Because("it should be consumed via the API, not directly");

        _ = rule.HasNoViolations(architecture).Should().BeTrue();
    }

    [Fact]
    public void NotAllowTheUiToDirectlyDependOnTheInfrastructureLayer()
    {
        IArchRule rule = Types().That().Are(uiLayer).Should()
            .NotDependOnAny(infrastructureLayer).Because("it should be consumed via the API, not directly");

        _ = rule.HasNoViolations(architecture).Should().BeTrue();
    }

    [Fact]
    public void NotAllowTheUiToDirectlyDependOnTheDomainModelLayer()
    {
        IArchRule rule = Types().That().Are(uiLayer).Should()
            .NotDependOnAny(domainModelLayer).Because("it should be consumed via the API, not directly");

        _ = rule.HasNoViolations(architecture).Should().BeTrue();
    }

    [Fact]
    public void NotAllowTheapiLayerToDirectlyDependOnTheUiLayer()
    {
        IArchRule rule = Types().That().Are(apiLayer).Should()
            .NotDependOnAny(uiLayer).Because("it should not need to access the UI namespace");

        _ = rule.HasNoViolations(architecture).Should().BeTrue();
    }

    [Fact]
    public void NotAllowTheapiLayerToDirectlyDependOnTheInfrastructureLayer()
    {
        IArchRule rule = Types().That().Are(apiLayer).Should()
            .NotDependOnAny(infrastructureLayer).Because("am sure we will need to remove this test");

        _ = rule.HasNoViolations(architecture).Should().BeTrue();
    }

    [Fact]
    public void NotAllowTheapiLayerToDirectlyDependOnTheDomainModelLayer()
    {
        IArchRule rule = Types().That().Are(apiLayer).Should()
            .NotDependOnAny(domainModelLayer).Because("it should not access the Domain Model directly.");

        _ = rule.HasNoViolations(architecture).Should().BeTrue();
    }
}
