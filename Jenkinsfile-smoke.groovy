/*
 * Requires: https://github.com/RedHatInsights/insights-pipeline-lib
 */

@Library("github.com/RedHatInsights/insights-pipeline-lib") _


// this 'if' statement makes sure this is a PR, so we don't run smoke tests again
// after code has been merged into the stable branch.
if (env.CHANGE_ID) {
    runSmokeTest (
        // the service-set/component for this app in e2e-deploy "buildfactory"
        ocDeployerBuilderPath: "sources/sources-api",
        // the service-set/component for this app in e2e-deploy "templates"
        ocDeployerComponentPath: "sources/sources-api",
        // the service sets to deploy into the test environment
        ocDeployerServiceSets: "platform-mq,sources",
        // the iqe plugins to install for the test
        iqePlugins: ["iqe-sources-plugin"],
        // the pytest marker to use when calling `iqe tests all`
        pytestMarker: "sources_smoke",
        // Config file for tests
        configFileCredentialsId: "sources-config"
    )
}
