defprotocol WhiteBread.Outputers.ProgressReporter do
  @fallback_to_any true
  def report(progress_reporter, report_tuple)
end

defimpl WhiteBread.Outputers.ProgressReporter,
for: [WhiteBread.Outputers.Console] do
  def report(progress_reporter, report_tuple) do
    send progress_reporter.pid, report_tuple
  end
end

defimpl WhiteBread.Outputers.ProgressReporter, for: Any do
  def report(nil, _report_tuple), do: :skipped
end
