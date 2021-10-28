# How to become a contributor and submit your own code

1. Submit an issue on GitHub describing your proposed change to this repo
1. A repo owner will respond to your issue promptly
1. Fork the repo, develop and test your code changes
1. Ensure that your code adheres to the existing style in the code to which you are contributing
1. Ensure that your code has an appropriate set of tests which all pass
1. Title your pull request following [Conventional Commits](https://www.conventionalcommits.org/) styling
1. Submit a pull request.

## Policy on inclusive language

To make Grift a pleasant and effective experience for everyone, we use try to use inclusive language.

These resources can help:

- Google's tutorial [Writing inclusive documentation](https://developers.google.com/style/inclusive-documentation) teaches by example, how to reword non-inclusive things.
- Linux kernel mailing list's [Coding Style: Inclusive Terminology](https://lkml.org/lkml/2020/7/4/229) said "Add no new instances of non-inclusive words, here is a list of words not include new ones of."
- Linguistic Society of America published [Guidelines for Inclusive Language](https://www.linguisticsociety.org/resource/guidelines-inclusive-language) which concluded: "We encourage all linguists to consider the possible reactions of their potential audience to their writing and, in so doing, to choose expository practices and content that is positive, inclusive, and respectful."

This project attempts to improve in these areas. Join us in doing that important work.

## Required checks

Before pushing your code and opening a PR, we recommend you run the following checks to avoid
our GitHub Actions Workflow to block your contribution.

```bash
# install dependencies
$ bundle install

# Run unit tests and check code coverage
$ bundle exec rake test

# Check code style
$ bundle exec rubocop
```
