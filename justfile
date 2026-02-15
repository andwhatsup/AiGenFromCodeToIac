clear:
    rm -rf log
    rm -rf out
    rm -rf workspace
    mkdir -p log
    mkdir -p out
    mkdir -p workspace

run:
    set dotenv-load
    set export
    python src/main.py
