import sys
import subprocess
import shlex
from os import path
import os
import ansicolors
import pathlib
import shutil

from dataclasses import dataclass

MARS_MAX_STEPS = 1000000
MARS_FAILURE_EXIT_CODE = 1
MARS_PATH = './mars'
    
mars_flags = [
    f"ae{MARS_FAILURE_EXIT_CODE}", # terminate MARS with integer exit code {N} if assembly error occurs,
    "me", # display MARS messages to standard err instead of standard out,
    "nc", # copyright notice will not be displayed
    "sm", # start executio nat statement having global label 'main' if defined
    f"{MARS_MAX_STEPS}", # {N} is in integer maximum count of execution steps to simulate
]

def assure_directory(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def rm_path(path):
    try:
        shutil.rmtree(path)
    except FileNotFoundError:
        pass


@dataclass
class TestResult:
    test_name: str
    success: bool
    output_differs: bool
    time: int | None
    stderr: str
    output: str
    returncode: int

    def __bool__(self):
        return self.success and not self.output_differs and self.returncode == 0 and self.stderr == "\n"

    def verdict(self):
        if self.__bool__():
            return f"{ansicolors.green('Success')}"
        else:
            if self.output_differs:
                return f"{ansicolors.red('Failure')} (Output differs)"
            elif self.stderr:
                return f"{ansicolors.red('Failure')} (Terminated with errors)"
            else:
                return f"{ansicolors.red('Failure')} (Exit code {self.returncode})"

    def json(self):
        return {
            "caseId": self.test_name,
            "errors": [],
            "successful": self.__bool__(),
            "time": self.time,
            "stdout": self.output,
            "stderr": self.stderr,
        }

@dataclass
class MipsTest:
    name: str
    substitutions: dict[pathlib.Path, pathlib.Path] # implementation_path -> testsuite_path
    implementation_path: pathlib.Path
    reference_path: pathlib.Path # file containing the expected output

    def get_sources(self) -> list[pathlib.Path]:
        files = [ file for file in self.implementation_path.glob('*.s') ]
        return [ file if file not in self.substitutions else self.substitutions[file] for file in files ]
    
    def execute(self, marsPath=MARS_PATH, mars_flags=mars_flags):
        flags_str = " ".join(mars_flags)
        sources = self.get_sources()
        sources_str = " ".join([ str(source) for source in sources])
        return subprocess.run(shlex.split(f"{marsPath} {flags_str} {sources_str}"), check=False, capture_output=True)

    def execute_for_runtime(self, marsPath=MARS_PATH, mars_flags=mars_flags):
        mini = 32
        maxi = MARS_MAX_STEPS
        
        while maxi > mini + 1:
            bound = (maxi + mini) // 2
            time_flags = [
                f"ae{MARS_FAILURE_EXIT_CODE}", # terminate MARS with integer exit code {N} if assembly error occurs,
                "me", # display MARS messages to standard err instead of standard out,
                "nc", # copyright notice will not be displayed
                "sm", # start executio nat statement having global label 'main' if defined
                f"{bound}", # {N} is in integer maximum count of execution steps to simulate
            ]
            t = self.run_test(marsPath=marsPath, mars_flags=time_flags, get_runtime=False)
            needle = f"Program terminated when maximum step limit {bound} reached."
            if needle in t.stderr: # program ran into bound
                mini = bound
            else: # terminated within bound
                maxi = bound
        return bound + 1

    def run_test(self, marsPath=MARS_PATH, mars_flags=mars_flags, get_runtime=False):
        t = self.execute(marsPath=MARS_PATH, mars_flags=mars_flags)
        ret = t.returncode
        output = t.stdout
        if ret != 0:
            return TestResult(self.name, False, False, None, t.stderr.decode(), t.stdout.decode(), ret)
        diffResult = subprocess.run(shlex.split(f"diff --strip-trailing-cr -w -q {self.reference_path} -"), check=False, capture_output=True, input=output)
        if diffResult.returncode == 0:
            time_measure = self.execute_for_runtime(marsPath=MARS_PATH, mars_flags=mars_flags) if get_runtime else None
            return TestResult(self.name, True, False, time_measure, t.stderr.decode(), t.stdout.decode(), ret)
        else:
            return TestResult(self.name, True, True, None, t.stderr.decode(), t.stdout.decode(), ret)

    def build_testbox(self):
        testbox = pathlib.Path('./debugbox')
        if testbox.exists():
            if not input("Delete old ./debugbox? [y/n] ") == "y":
                print("Aborting!")
                exit(1)
        rm_path(testbox)
        assure_directory(testbox)
        for file in self.get_sources():
            shutil.copy(file, testbox)
