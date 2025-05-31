# Sample Node.js application

This repository is a sample Node.js application for Docker's documentation.

[Project Link on roadmap.sh](https://roadmap.sh/projects/dockerized-service-deployment)

Ref: 
[google-github-actions/auth](https://github.com/google-github-actions/auth/tree/v2/?tab=readme-ov-file#indirect-wif)
[google-github-actions/deploy-gke](https://github.com/google-github-actions/deploy-gke/tree/v0.0.3/)

# Setup step
![Authenticate to Google Cloud from GitHub Actions with Workload Identity Federation through a Service Account](https://github.com/google-github-actions/auth/raw/v2/docs/google-github-actions-auth-workload-identity-federation-through-service-account.svg)

<details>
  <summary>Click here to show detailed instructions for configuring GitHub authentication to Google Cloud via a Workload Identity Federation through a Service Account.</summary>

These instructions use the [gcloud][gcloud] command-line tool.

1.  (Optional) Create a Google Cloud Service Account. If you already have a
    Service Account, take note of the email address and skip this step.

    ```sh
    # TODO: replace ${PROJECT_ID} with your value below.

    gcloud iam service-accounts create "my-service-account" \
      --project "${PROJECT_ID}"
    ```

1.  Create a Workload Identity Pool:

    ```sh
    # TODO: replace ${PROJECT_ID} with your value below.

    gcloud iam workload-identity-pools create "github" \
      --project="${PROJECT_ID}" \
      --location="global" \
      --display-name="GitHub Actions Pool"
    ```

1.  Get the full ID of the Workload Identity **Pool**:

    ```sh
    # TODO: replace ${PROJECT_ID} with your value below.

    gcloud iam workload-identity-pools describe "github" \
      --project="${PROJECT_ID}" \
      --location="global" \
      --format="value(name)"
    ```

    This value should be of the format:

    ```text
    projects/123456789/locations/global/workloadIdentityPools/github
    ```

1.  Create a Workload Identity **Provider** in that pool:

    **🛑 CAUTION!** Always add an Attribute Condition to restrict entry into the
    Workload Identity Pool. You can further restrict access in IAM Bindings, but
    always add a basic condition that restricts admission into the pool. A good
    default option is to restrict admission based on your GitHub organization as
    demonstrated below. Please see the [security considerations](https://cloud.google.com/iam/docs/workload-identity-federation#security-considerations) for more details.

    ```sh
    # TODO: replace ${PROJECT_ID} and ${GITHUB_ORG} with your values below.

    gcloud iam workload-identity-pools providers create-oidc "my-repo" \
      --project="${PROJECT_ID}" \
      --location="global" \
      --workload-identity-pool="github" \
      --display-name="My GitHub repo Provider" \
      --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
      --attribute-condition="assertion.repository_owner == '${GITHUB_ORG}'" \
      --issuer-uri="https://token.actions.githubusercontent.com"
    ```

    > **❗️ IMPORTANT** You must map any claims in the incoming token to
    > attributes before you can assert on those attributes in a CEL expression
    > or IAM policy!

1.  Allow authentications from the Workload Identity Pool to your Google Cloud
    Service Account.

    ```sh
    # TODO: replace ${PROJECT_ID}, ${WORKLOAD_IDENTITY_POOL_ID}, and ${REPO}
    # with your values below.
    #
    # ${REPO} is the full repo name including the parent GitHub organization,
    # such as "my-org/my-repo".
    #
    # ${WORKLOAD_IDENTITY_POOL_ID} is the full pool id, such as
    # "projects/123456789/locations/global/workloadIdentityPools/github".

    gcloud iam service-accounts add-iam-policy-binding "my-service-account@${PROJECT_ID}.iam.gserviceaccount.com" \
      --project="${PROJECT_ID}" \
      --role="roles/iam.workloadIdentityUser" \
      --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
    ```

    Review the [GitHub documentation][github-oidc] for a complete list of
    options and values. This GitHub repository does not seek to enumerate every
    possible combination.

1.  Extract the Workload Identity **Provider** resource name:

    ```sh
    # TODO: replace ${PROJECT_ID} with your value below.

    gcloud iam workload-identity-pools providers describe "my-repo" \
      --project="${PROJECT_ID}" \
      --location="global" \
      --workload-identity-pool="github" \
      --format="value(name)"
    ```

    Use this value as the `workload_identity_provider` value in the GitHub
    Actions YAML:

    ```yaml
    - uses: 'google-github-actions/auth@v2'
      with:
        service_account: '...' # my-service-account@my-project.iam.gserviceaccount.com
        workload_identity_provider: '...' # "projects/123456789/locations/global/workloadIdentityPools/github/providers/my-repo"
    ```

1.  As needed, grant the Google Cloud Service Account permissions to access
    Google Cloud resources. This step varies by use case. The following example
    shows granting access to a secret in Google Secret Manager.

    ```sh
    # TODO: replace ${PROJECT_ID} with your value below.

    gcloud secrets add-iam-policy-binding "my-secret" \
      --project="${PROJECT_ID}" \
      --role="roles/secretmanager.secretAccessor" \
      --member="serviceAccount:my-service-account@${PROJECT_ID}.iam.gserviceaccount.com"
    ```
</details>