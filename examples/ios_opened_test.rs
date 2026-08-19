// Copyright 2021-2026 Tauri Programme within The Commons Conservancy
// SPDX-License-Identifier: Apache-2.0

#[cfg(target_os = "ios")]
fn main() {
  use std::{
    fs::{File, OpenOptions},
    io::Write,
  };

  use tao::{
    event::{Event, StartCause},
    event_loop::{ControlFlow, EventLoop},
  };

  const LOG_FILE: &str = "tao-opened-test.log";

  fn record(message: &str) {
    eprintln!("{message}");
    let path = std::env::temp_dir().join(LOG_FILE);
    if let Ok(mut file) = OpenOptions::new().append(true).open(path) {
      let _ = writeln!(file, "{message}");
    }
  }

  File::create(std::env::temp_dir().join(LOG_FILE)).expect("failed to create test log");
  std::panic::set_hook(Box::new(|info| record(&format!("PANIC {info}"))));

  // Intentionally do not create a window or open a URL.
  EventLoop::new().run(|event, _, control_flow| {
    *control_flow = ControlFlow::Wait;
    if let Event::NewEvents(StartCause::Init) = event {
      record("EVENT_LOOP_INIT");
    }
  })
}

#[cfg(not(target_os = "ios"))]
fn main() {}
