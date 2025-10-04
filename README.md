# Gotsha — your local CI (alpha coming soon)
Pushing untested commits? Gotsha!

## What is it?
Gotsha is a tiny tool that lets you “sign off” your commit locally: it runs your tests and then stores the test results with the commit SHA (hence the gem name: got-SHA). Your pull request can then be verified against that record, so reviewers know you actually ran the checks before asking for review.

And the best part? It all happens automatically!

<img width="664" height="523" alt="image" src="https://github.com/user-attachments/assets/6acb4a69-c405-420e-9a05-9b28df4ea1f0" />

Then, you can see the tests results in a Github action:

<img width="1022" height="858" alt="image" src="https://github.com/user-attachments/assets/cf5d6492-02a0-47ee-81ee-4e34234a7983" />

(Screenshots from a real [demo pull request](https://github.com/melounvitek/gotsha/pull/35); feel free to check it!)

Based on your workflow and tests speed, you can configure them to auto-run on every commit, before every push, or just manually. Whenever pushing to remote repository, the Git notes (which is what's used to store the test results) get sent there as well.

Instead of pushing everything to CI, you can run the same checks locally (faster, cheaper, works offline) and prove you did it. Gotsha will make this proof visible in your pull request.
